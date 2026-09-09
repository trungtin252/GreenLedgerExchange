#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"

check_prerequisites
require_local_env
compose --profile core --profile apps up -d postgres registry
compose exec -T -e 'PGPASSWORD=${REGISTRY_DB_PASSWORD}' postgres psql -h localhost -U registry_runtime -d glx_registry -v ON_ERROR_STOP=1 -c "
INSERT INTO organization_profile (id, external_reference, display_name)
VALUES
  ('00000000-0000-0000-0000-000000000001', 'GLX-DEMO-ORG-001', 'GLX Demo Forest Cooperative'),
  ('00000000-0000-0000-0000-000000000002', 'GLX-DEMO-ORG-002', 'GLX Demo Manufacturing'),
  ('00000000-0000-0000-0000-000000000003', 'GLX-DEMO-ORG-003', 'GLX Demo Civic Fund')
ON CONFLICT (external_reference) DO UPDATE SET display_name = EXCLUDED.display_name;"
printf 'Seeded three synthetic organization profiles idempotently. No instruments, orders, payments, or retirements were created.\n'
