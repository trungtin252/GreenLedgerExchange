#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"

check_prerequisites
if [[ ! -f "$GLX_ROOT/.env" ]]; then
  cp "$GLX_ROOT/.env.example" "$GLX_ROOT/.env"
  printf 'Created .env from .env.example. Fill every required synthetic local value, then rerun bootstrap.\n'
fi
require_local_env
ensure_lockfiles

pnpm install --frozen-lockfile
(cd "$GLX_ROOT/services/ai-verification" && uv sync --locked --all-groups)
compose --profile core pull
"$GLX_ROOT/scripts/verify.sh" --quick
