[CmdletBinding()]
param()
. (Join-Path $PSScriptRoot 'Common.ps1')

Test-Prerequisites; Test-LocalEnv
Invoke-Compose @('--profile', 'core', '--profile', 'apps', 'up', '-d', 'postgres', 'registry')
$sql = @"
INSERT INTO organization_profile (id, external_reference, display_name)
VALUES
  ('00000000-0000-0000-0000-000000000001', 'GLX-DEMO-ORG-001', 'GLX Demo Forest Cooperative'),
  ('00000000-0000-0000-0000-000000000002', 'GLX-DEMO-ORG-002', 'GLX Demo Manufacturing'),
  ('00000000-0000-0000-0000-000000000003', 'GLX-DEMO-ORG-003', 'GLX Demo Civic Fund')
ON CONFLICT (external_reference) DO UPDATE SET display_name = EXCLUDED.display_name;
"@
Invoke-Compose @('exec', '-T', '-e', 'PGPASSWORD=${REGISTRY_DB_PASSWORD}', 'postgres', 'psql', '-h', 'localhost', '-U', 'registry_runtime', '-d', 'glx_registry', '-v', 'ON_ERROR_STOP=1', '-c', $sql)
Write-Host 'Seeded three synthetic organization profiles idempotently. No instruments, orders, payments, or retirements were created.'
