[CmdletBinding()]
param()
. (Join-Path $PSScriptRoot 'Common.ps1')

Test-Prerequisites
$envFile = Join-Path $script:GlxRoot '.env'
if (-not (Test-Path $envFile)) {
  Copy-Item (Join-Path $script:GlxRoot '.env.example') $envFile
  Write-Host 'Created .env from .env.example. Fill every required synthetic local value, then rerun bootstrap.'
}
Test-LocalEnv
Test-Lockfiles
Push-Location $script:GlxRoot
try {
  Invoke-Pnpm @('install', '--frozen-lockfile')
  Push-Location 'services/ai-verification'
  try { Invoke-Uv @('sync', '--locked', '--all-groups') } finally { Pop-Location }
} finally { Pop-Location }
Invoke-Compose @('--profile', 'core', 'pull')
& (Join-Path $PSScriptRoot 'verify.ps1') '--quick'
