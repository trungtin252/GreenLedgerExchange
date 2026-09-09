Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$script:GlxRoot = Split-Path -Parent $PSScriptRoot
$script:GlxTools = Join-Path $script:GlxRoot '.tools'
$script:GlxUvExecutable = Join-Path $script:GlxTools 'uv\uv.exe'
if (-not $env:MAVEN_USER_HOME) { $env:MAVEN_USER_HOME = Join-Path $script:GlxRoot '.local/maven' }
$env:npm_config_cache = Join-Path $script:GlxTools 'npm-cache'
$env:UV_CACHE_DIR = Join-Path $script:GlxTools 'uv-cache'
$env:PLAYWRIGHT_BROWSERS_PATH = '0'

function Stop-Glx([string] $Message) {
  throw "GLX bootstrap error: $Message"
}

function Get-CommandOutput([string] $Command, [string[]] $Arguments) {
  $resolvedCommand = Get-Command $Command -ErrorAction SilentlyContinue | Select-Object -First 1
  if (-not $resolvedCommand) { Stop-Glx "$Command is not installed." }
  if ([string]::IsNullOrWhiteSpace($resolvedCommand.Path)) { Stop-Glx "$Command does not resolve to an executable path." }
  $process = [System.Diagnostics.Process]::new()
  $process.StartInfo.UseShellExecute = $false
  $process.StartInfo.RedirectStandardOutput = $true
  $process.StartInfo.RedirectStandardError = $true
  $argumentLine = ($Arguments | ForEach-Object {
    if ($_ -match '[\s"]') { '"' + $_.Replace('"', '\"') + '"' } else { $_ }
  }) -join ' '
  if ([IO.Path]::GetExtension($resolvedCommand.Path) -in @('.cmd', '.bat')) {
    $process.StartInfo.FileName = $env:ComSpec
    $process.StartInfo.Arguments = "/d /s /c `"`"$($resolvedCommand.Path)`" $argumentLine`""
  } else {
    $process.StartInfo.FileName = $resolvedCommand.Path
    $process.StartInfo.Arguments = $argumentLine
  }
  [void]$process.Start()
  $standardOutput = $process.StandardOutput.ReadToEnd()
  $standardError = $process.StandardError.ReadToEnd()
  $process.WaitForExit()
  $value = ($standardOutput + $standardError).Trim()
  if ($process.ExitCode -ne 0) { Stop-Glx "$Command failed: $value" }
  return $value
}

function Invoke-Pnpm([string[]] $Arguments) {
  if (-not (Get-Command npx -ErrorAction SilentlyContinue)) { Stop-Glx 'npx is unavailable. Node.js 22.12.0 must include npm and npx.' }
  & npx --yes '--package=pnpm@10.28.2' pnpm @Arguments
  if ($LASTEXITCODE -ne 0) { Stop-Glx 'Project-local pnpm command failed.' }
}

function Invoke-Uv([string[]] $Arguments) {
  if (-not (Test-Path $script:GlxUvExecutable)) {
    Stop-Glx "Project-local uv is missing at '$script:GlxUvExecutable'. Install it under .tools/uv as documented in README.md."
  }
  & $script:GlxUvExecutable @Arguments
  if ($LASTEXITCODE -ne 0) { Stop-Glx 'Project-local uv command failed.' }
}

function Test-GitOwnership {
  $result = & git -C $script:GlxRoot status --porcelain 2>&1
  if ($LASTEXITCODE -ne 0) {
    $text = $result | Out-String
    if ($text -match 'dubious ownership') {
      Stop-Glx "Git reports dubious ownership. Ask the repository owner to run: git config --global --add safe.directory '$script:GlxRoot'"
    }
    Stop-Glx "git status failed: $text"
  }
}

function Test-Prerequisites {
  $javaLine = (((Get-CommandOutput 'java' @('-version')) -split "`n")[0]).Trim()
  if ($javaLine -notmatch '"21(\.|"|$)') { Stop-Glx "JDK is '$javaLine'; required major version '21'. Update PATH for this shell." }
  $nodeVersion = Get-CommandOutput 'node' @('--version')
  if ($nodeVersion -ne 'v22.12.0') { Stop-Glx "Node.js is '$nodeVersion'; required 'v22.12.0'. Use .node-version, then reopen the shell." }
  if (-not (Get-Command npx -ErrorAction SilentlyContinue)) { Stop-Glx 'npx is unavailable. Node.js 22.12.0 must include npm and npx.' }
  if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { Stop-Glx 'Docker Desktop with Compose V2 is required.' }
  [void](Get-CommandOutput 'docker' @('compose', 'version'))
  $pythonCommand = if (Get-Command python -ErrorAction SilentlyContinue) { 'python' } elseif (Get-Command py -ErrorAction SilentlyContinue) { 'py' } else { Stop-Glx 'Python 3.11 is not installed.' }
  $pythonArgs = if ($pythonCommand -eq 'py') { @('-3.11', '--version') } else { @('--version') }
  $pythonVersion = Get-CommandOutput $pythonCommand $pythonArgs
  if ($pythonVersion -notmatch '^Python 3\.11\.') { Stop-Glx "Python is '$pythonVersion'; required 'Python 3.11'." }
  if (-not (Test-Path $script:GlxUvExecutable)) { Stop-Glx "Project-local uv is missing at '$script:GlxUvExecutable'. Install it under .tools/uv as documented in README.md." }
  $mavenLine = (((Get-CommandOutput 'mvn' @('--version')) -split "`n")[0]).Trim()
  if ($mavenLine -notmatch '^Apache Maven 3\.9\.') { Stop-Glx "Maven is '$mavenLine'; required version '3.9.7 or later in the 3.9 line'." }
  Test-GitOwnership
}

function Test-LocalEnv {
  $envFile = Join-Path $script:GlxRoot '.env'
  if (-not (Test-Path $envFile)) { Stop-Glx '.env is missing. Run scripts/bootstrap.ps1 first.' }
  $text = Get-Content $envFile -Raw
  foreach ($key in 'GLX_POSTGRES_SUPERUSER_PASSWORD', 'REGISTRY_DB_PASSWORD', 'EXCHANGE_DB_PASSWORD', 'REGISTRY_MIGRATOR_PASSWORD', 'EXCHANGE_MIGRATOR_PASSWORD', 'GATEWAY_SESSION_REDIS_PASSWORD', 'KEYCLOAK_ADMIN_PASSWORD', 'MINIO_ROOT_USER', 'MINIO_ROOT_PASSWORD') {
    if ($text -notmatch "(?m)^$key=.+$") { Stop-Glx ".env value '$key' is empty. Use a synthetic local-only value." }
  }
}

function Test-Lockfiles {
  if (-not (Test-Path (Join-Path $script:GlxRoot 'pnpm-lock.yaml'))) { Stop-Glx 'pnpm-lock.yaml is missing. Run project-local pnpm through scripts/bootstrap.ps1 after restoring the lockfile.' }
  if (-not (Test-Path (Join-Path $script:GlxRoot 'services/ai-verification/uv.lock'))) { Stop-Glx 'services/ai-verification/uv.lock is missing. Run .tools/uv/uv.exe lock --project services/ai-verification.' }
}

function Invoke-Compose([string[]] $Arguments) {
  Push-Location $script:GlxRoot
  try { & docker compose @Arguments; if ($LASTEXITCODE -ne 0) { Stop-Glx 'docker compose failed.' } } finally { Pop-Location }
}
