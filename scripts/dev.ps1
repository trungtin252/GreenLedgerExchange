[CmdletBinding()]
param([Parameter(Position = 0, Mandatory = $true)][string] $Action, [Parameter(ValueFromRemainingArguments = $true)][string[]] $Services)
. (Join-Path $PSScriptRoot 'Common.ps1')

switch ($Action) {
  'up' {
    Test-Prerequisites; Test-LocalEnv
    $profiles = if ($Services.Count -gt 0) { $Services } else { @('core', 'apps') }
    $arguments = @()
    foreach ($profile in $profiles) { $arguments += @('--profile', $profile) }
    $arguments += @('up', '-d', '--build')
    Invoke-Compose $arguments
  }
  'down' { Invoke-Compose @('down') }
  'status' { Invoke-Compose @('ps') }
  'logs' { Invoke-Compose (@('logs', '--tail=200', '-f') + $Services) }
  default { Stop-Glx 'Usage: scripts/dev.ps1 up [core apps obs provider] | down | status | logs [service...]' }
}
