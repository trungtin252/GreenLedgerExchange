#!/usr/bin/env bash
set -euo pipefail

GLX_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GLX_TOOLS="$GLX_ROOT/.tools"
UV_BIN="$GLX_TOOLS/uv/uv"
: "${MAVEN_USER_HOME:=$GLX_ROOT/.local/maven}"
export MAVEN_USER_HOME
export npm_config_cache="$GLX_TOOLS/npm-cache"
export UV_CACHE_DIR="$GLX_TOOLS/uv-cache"
export PLAYWRIGHT_BROWSERS_PATH=0

fail() {
  printf 'GLX bootstrap error: %s\n' "$*" >&2
  exit 1
}

require_exact() {
  local label="$1" expected="$2" actual="$3" remediation="$4"
  if [[ "$actual" != "$expected" ]]; then
    fail "$label is '$actual'; required '$expected'. $remediation"
  fi
}

command_version() {
  local command_name="$1"
  command -v "$command_name" >/dev/null 2>&1 || fail "$command_name is not installed. $2"
  "$command_name" "${@:3}"
}

pnpm() {
  command -v npx >/dev/null 2>&1 || fail "npx is unavailable. Node.js 22.12.0 must include npm and npx."
  npx --yes --package=pnpm@10.28.2 pnpm "$@"
}

uv() {
  [[ -x "$UV_BIN" ]] || fail "Project-local uv is missing at '$UV_BIN'. Install it under .tools/uv as documented in README.md."
  "$UV_BIN" "$@"
}

check_git_ownership() {
  local error_file
  error_file="$(mktemp)"
  if ! git -C "$GLX_ROOT" status --porcelain >/dev/null 2>"$error_file"; then
    if grep -qi 'dubious ownership' "$error_file"; then
      rm -f "$error_file"
      fail "Git reports dubious ownership. Ask the repository owner to run: git config --global --add safe.directory '$GLX_ROOT'"
    fi
    local message
    message="$(<"$error_file")"
    rm -f "$error_file"
    fail "Git status failed: $message"
  fi
  rm -f "$error_file"
}

check_prerequisites() {
  local java_version node_version python_version maven_version
  command -v java >/dev/null 2>&1 || fail "JDK 21 is not installed. Install JDK 21 and ensure java is on PATH."
  java_version="$(java -version 2>&1 | awk -F'"' '/version/{print $2; exit}')"
  [[ "$java_version" == 21.* ]] || fail "JDK is '$java_version'; required major version '21'. Update PATH for this shell."

  command -v node >/dev/null 2>&1 || fail "Node.js 22.12.0 is not installed. Install it before continuing."
  node_version="$(node --version)"
  require_exact "Node.js" "v22.12.0" "$node_version" "Use the version in .node-version, then reopen the shell."

  command -v npx >/dev/null 2>&1 || fail "npx is unavailable. Node.js 22.12.0 must include npm and npx."

  command -v docker >/dev/null 2>&1 || fail "Docker Desktop with Compose V2 is required. Install and start Docker Desktop."
  docker compose version >/dev/null 2>&1 || fail "Docker Compose V2 is unavailable. Install or enable Docker Compose V2."

  if command -v python3 >/dev/null 2>&1; then
    python_version="$(python3 --version | awk '{print $2}')"
  elif command -v python >/dev/null 2>&1; then
    python_version="$(python --version | awk '{print $2}')"
  else
    fail "Python 3.11 is not installed. Install Python 3.11 and add it to PATH."
  fi
  [[ "$python_version" == 3.11.* ]] || fail "Python is '$python_version'; required '3.11'. Install Python 3.11."

  [[ -x "$UV_BIN" ]] || fail "Project-local uv is missing at '$UV_BIN'. Install it under .tools/uv as documented in README.md."
  command -v mvn >/dev/null 2>&1 || fail "Maven 3.9 is not installed. Install Maven 3.9.7 or later in the 3.9 line."
  maven_version="$(mvn --version 2>&1 | awk '/Apache Maven/{print $3; exit}')"
  [[ "$maven_version" == 3.9.* ]] || fail "Maven is '$maven_version'; required '3.9.7 or later in the 3.9 line'."
  check_git_ownership
}

require_local_env() {
  [[ -f "$GLX_ROOT/.env" ]] || fail ".env is missing. Run scripts/bootstrap first."
  local key
  for key in GLX_POSTGRES_SUPERUSER_PASSWORD REGISTRY_DB_PASSWORD EXCHANGE_DB_PASSWORD REGISTRY_MIGRATOR_PASSWORD EXCHANGE_MIGRATOR_PASSWORD GATEWAY_SESSION_REDIS_PASSWORD KEYCLOAK_ADMIN_PASSWORD MINIO_ROOT_USER MINIO_ROOT_PASSWORD; do
    grep -Eq "^${key}=.+" "$GLX_ROOT/.env" || fail ".env value '$key' is empty. Use a synthetic local-only value."
  done
}

ensure_lockfiles() {
  [[ -f "$GLX_ROOT/pnpm-lock.yaml" ]] || fail "pnpm-lock.yaml is missing. Run project-local pnpm through scripts/bootstrap after restoring the lockfile."
  [[ -f "$GLX_ROOT/services/ai-verification/uv.lock" ]] || fail "services/ai-verification/uv.lock is missing. Run .tools/uv/uv lock --project services/ai-verification."
}

compose() {
  (cd "$GLX_ROOT" && docker compose "$@")
}
