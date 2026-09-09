#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"

mode="${1:-}"
[[ "$mode" == "--quick" || "$mode" == "--full" ]] || fail "Usage: scripts/verify.sh --quick|--full"
check_prerequisites
require_local_env
ensure_lockfiles

(cd "$GLX_ROOT" && mvn --batch-mode help:effective-pom -Doutput=target/effective-pom.xml)
(cd "$GLX_ROOT" && mvn --batch-mode test)
(cd "$GLX_ROOT" && pnpm --filter @glx/contracts run check)
(cd "$GLX_ROOT" && pnpm --filter @glx/web-portal run lint && pnpm --filter @glx/web-portal run typecheck && pnpm --filter @glx/web-portal run test && pnpm --filter @glx/web-portal run build)
(cd "$GLX_ROOT/services/ai-verification" && uv run ruff check . && uv run pyright && uv run pytest)

if [[ "$mode" == "--full" ]]; then
  compose --profile core --profile apps up -d --build
  for endpoint in http://localhost:8080/actuator/health/readiness http://localhost:8081/actuator/health/readiness http://localhost:8082/actuator/health/readiness http://localhost:8090/readyz; do
    for attempt in {1..30}; do curl --fail --silent "$endpoint" >/dev/null && break; sleep 2; done
    curl --fail --silent "$endpoint" >/dev/null || fail "Runtime did not become ready: $endpoint"
  done
  (cd "$GLX_ROOT" && mvn --batch-mode verify org.cyclonedx:cyclonedx-maven-plugin:2.9.1:makeAggregateBom)
  (cd "$GLX_ROOT" && pnpm --filter @glx/e2e run test)
  docker run --rm -v "$GLX_ROOT:/repo:ro" zricethezav/gitleaks:v8.30.0 detect --config=/repo/.gitleaks.toml --source=/repo --no-git
  mkdir -p "$GLX_ROOT/.local/trivy"
  trivy_docker_args=(--rm --workdir /repo -v "$GLX_ROOT:/repo:ro" -v "$GLX_ROOT/.local/trivy:/root/.cache/trivy")
  trivy_security_args=(--quiet --exit-code 1 --severity HIGH,CRITICAL)
  trivy_run() { docker run "${trivy_docker_args[@]}" aquasec/trivy:0.67.0 "$@"; }
  trivy_run sbom "${trivy_security_args[@]}" /repo/target/bom.json
  trivy_run fs "${trivy_security_args[@]}" --scanners vuln pnpm-lock.yaml
  trivy_run fs "${trivy_security_args[@]}" --scanners vuln services/ai-verification/uv.lock
  for dockerfile in apps/web-portal/Dockerfile services/ai-verification/Dockerfile services/exchange-service/Dockerfile services/gateway-bff/Dockerfile services/registry-mrv-service/Dockerfile; do
    trivy_run config "${trivy_security_args[@]}" "$dockerfile"
  done
  compose config --quiet
fi
