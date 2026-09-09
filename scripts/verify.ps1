[CmdletBinding()]
param([Parameter(Mandatory = $true)][ValidateSet('--quick', '--full')][string] $Mode)
. (Join-Path $PSScriptRoot 'Common.ps1')

Test-Prerequisites; Test-LocalEnv; Test-Lockfiles
Push-Location $script:GlxRoot
try {
  & mvn --batch-mode help:effective-pom '-Doutput=target/effective-pom.xml'
  if ($LASTEXITCODE -ne 0) { Stop-Glx 'Maven effective POM failed.' }
  & mvn --batch-mode test
  if ($LASTEXITCODE -ne 0) { Stop-Glx 'Java unit/module tests failed.' }
  Invoke-Pnpm @('--filter', '@glx/contracts', 'run', 'check')
  Invoke-Pnpm @('--filter', '@glx/web-portal', 'run', 'lint')
  Invoke-Pnpm @('--filter', '@glx/web-portal', 'run', 'typecheck')
  Invoke-Pnpm @('--filter', '@glx/web-portal', 'run', 'test')
  Invoke-Pnpm @('--filter', '@glx/web-portal', 'run', 'build')
  Push-Location 'services/ai-verification'
  try {
    Invoke-Uv @('run', 'ruff', 'check', '.')
    Invoke-Uv @('run', 'pyright')
    Invoke-Uv @('run', 'pytest')
  } finally { Pop-Location }
} finally { Pop-Location }

if ($Mode -eq '--full') {
  Invoke-Compose @('--profile', 'core', '--profile', 'apps', 'up', '-d', '--build')
  foreach ($endpoint in 'http://localhost:8080/actuator/health/readiness', 'http://localhost:8081/actuator/health/readiness', 'http://localhost:8082/actuator/health/readiness', 'http://localhost:8090/readyz') {
    $ready = $false
    for ($attempt = 1; $attempt -le 30 -and -not $ready; $attempt++) { try { Invoke-WebRequest -UseBasicParsing $endpoint | Out-Null; $ready = $true } catch { Start-Sleep -Seconds 2 } }
    if (-not $ready) { Stop-Glx "Runtime did not become ready: $endpoint" }
  }
  Push-Location $script:GlxRoot
  try {
    & mvn --batch-mode verify org.cyclonedx:cyclonedx-maven-plugin:2.9.1:makeAggregateBom
    if ($LASTEXITCODE -ne 0) { Stop-Glx 'SBOM generation failed.' }
    Invoke-Pnpm @('--filter', '@glx/e2e', 'run', 'test')
  } finally { Pop-Location }
  & docker run --rm -v "${script:GlxRoot}:/repo:ro" zricethezav/gitleaks:v8.30.0 detect --config=/repo/.gitleaks.toml --source=/repo --no-git
  if ($LASTEXITCODE -ne 0) { Stop-Glx 'Gitleaks found a secret.' }
  $trivyCache = Join-Path $script:GlxRoot '.local\trivy'
  New-Item -ItemType Directory -Force -Path $trivyCache | Out-Null
  $trivyDockerArgs = @('--rm', '--workdir', '/repo', '-v', "${script:GlxRoot}:/repo:ro", '-v', "${trivyCache}:/root/.cache/trivy")
  $trivySecurityArgs = @('--quiet', '--exit-code', '1', '--severity', 'HIGH,CRITICAL')
  & docker run @trivyDockerArgs aquasec/trivy:0.67.0 sbom @trivySecurityArgs '/repo/target/bom.json'
  if ($LASTEXITCODE -ne 0) { Stop-Glx 'Trivy found a high or critical Java dependency finding.' }
  & docker run @trivyDockerArgs aquasec/trivy:0.67.0 fs @trivySecurityArgs '--scanners' 'vuln' 'pnpm-lock.yaml'
  if ($LASTEXITCODE -ne 0) { Stop-Glx 'Trivy found a high or critical JavaScript dependency finding.' }
  & docker run @trivyDockerArgs aquasec/trivy:0.67.0 fs @trivySecurityArgs '--scanners' 'vuln' 'services/ai-verification/uv.lock'
  if ($LASTEXITCODE -ne 0) { Stop-Glx 'Trivy found a high or critical Python dependency finding.' }
  foreach ($dockerfile in @('apps/web-portal/Dockerfile', 'services/ai-verification/Dockerfile', 'services/exchange-service/Dockerfile', 'services/gateway-bff/Dockerfile', 'services/registry-mrv-service/Dockerfile')) {
    & docker run @trivyDockerArgs aquasec/trivy:0.67.0 config @trivySecurityArgs $dockerfile
    if ($LASTEXITCODE -ne 0) { Stop-Glx "Trivy found a high or critical configuration finding in $dockerfile." }
  }
  Invoke-Compose @('config', '--quiet')
}
