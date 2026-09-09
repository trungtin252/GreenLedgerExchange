#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"

action="${1:-}"
shift || true
case "$action" in
  up)
    check_prerequisites
    require_local_env
    if [[ "$#" -eq 0 ]]; then
      profiles=(core apps)
    else
      profiles=("$@")
    fi
    args=()
    for profile in "${profiles[@]}"; do args+=(--profile "$profile"); done
    compose "${args[@]}" up -d --build
    ;;
  down)
    compose down
    ;;
  status)
    compose ps
    ;;
  logs)
    compose logs --tail=200 -f "${@}"
    ;;
  *)
    fail "Usage: scripts/dev.sh up [core apps obs provider] | down | status | logs [service...]"
    ;;
esac
