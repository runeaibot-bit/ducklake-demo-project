#!/usr/bin/env bash
set -euo pipefail

# End-to-end DuckFlix retest against a local DuckLake server.
#
# Usage:
#   ./scripts/retest-demo.sh
# Optional env:
#   DUCK_HOST (default: http://localhost:8080)
#   DUCK_TOKEN (preferred) or DUCK_API_KEY
#
# Notes:
# - Uses script-first workflow: validate -> plan -> apply -> load -> verify -> sample query.
# - If auth fails with HTTP 401 in non-OIDC mode, see known platform blocker:
#   https://github.com/Yacobolo/ducklake-dataplatform/issues/215

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DUCK_HOST="${DUCK_HOST:-http://localhost:8080}"

if ! command -v duck >/dev/null 2>&1; then
  echo "ERROR: 'duck' CLI not found in PATH" >&2
  exit 1
fi

# Best-effort dev token bootstrap (works only when server accepts legacy HS256 dev JWT flow).
if [[ -z "${DUCK_TOKEN:-}" && -z "${DUCK_API_KEY:-}" ]]; then
  if command -v go >/dev/null 2>&1 && [[ -f /tmp/jwtgen.go ]]; then
    DUCK_TOKEN="$(go run /tmp/jwtgen.go 2>/dev/null || true)"
    export DUCK_TOKEN
  fi
fi

run() {
  echo
  echo "=== $* ==="
  "$@"
}

run_duck() {
  if [[ -n "${DUCK_API_KEY:-}" ]]; then
    duck --host "$DUCK_HOST" --token "" --api-key "$DUCK_API_KEY" "$@"
  else
    duck --host "$DUCK_HOST" --token "${DUCK_TOKEN:-}" "$@"
  fi
}

set +e
run run_duck validate --config-dir "$PROJECT_ROOT/duck-config"
validate_code=$?

run run_duck plan --config-dir "$PROJECT_ROOT/duck-config" --no-color
plan_code=$?

run run_duck apply --config-dir "$PROJECT_ROOT/duck-config" --auto-approve --no-color
apply_code=$?
set -e

if [[ $validate_code -ne 0 || $plan_code -ne 0 || $apply_code -ne 0 ]]; then
  echo
  echo "Retest blocked before load/verify phase."
  echo "If this is HTTP 401 in local dev mode, track blocker:"
  echo "  https://github.com/Yacobolo/ducklake-dataplatform/issues/215"
  exit 1
fi

run "$SCRIPT_DIR/fetch-movielens.sh"
run "$SCRIPT_DIR/load-duckflix.sh"
run "$SCRIPT_DIR/verify-duckflix.sh"
run run_duck query execute --sql "SELECT COUNT(*) AS ratings_cnt FROM demo.silver.ratings"

echo

echo "Retest complete."