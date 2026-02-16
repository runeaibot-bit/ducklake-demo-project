#!/usr/bin/env bash
set -euo pipefail

# Retest the demo project against a local DuckLake server.
# Usage:
#   ./scripts/retest-demo.sh
# Optional env:
#   DUCK_HOST (default: http://localhost:8080)
#   DUCK_TOKEN (if unset, generated via /tmp/jwtgen.go with subject 'rune')

DUCK_HOST="${DUCK_HOST:-http://localhost:8080}"

if [[ -z "${DUCK_TOKEN:-}" ]]; then
  DUCK_TOKEN=$(cd /root/.openclaw/workspace/ducklake-dataplatform && \
    PATH="$PATH:/usr/local/go/bin:/root/go/bin" go run /tmp/jwtgen.go rune 2>/dev/null)
fi

run() {
  echo
  echo "=== $* ==="
  "$@"
}

run duck --host "$DUCK_HOST" --token "$DUCK_TOKEN" validate --config-dir duck-config
run duck --host "$DUCK_HOST" --token "$DUCK_TOKEN" plan --config-dir duck-config --no-color || true
run duck --host "$DUCK_HOST" --token "$DUCK_TOKEN" apply --config-dir duck-config --auto-approve --no-color || true

run duck --host "$DUCK_HOST" --token "$DUCK_TOKEN" catalog list-registrations || true
run duck --host "$DUCK_HOST" --token "$DUCK_TOKEN" catalog schemas list demo || true
run duck --host "$DUCK_HOST" --token "$DUCK_TOKEN" catalog tables list titanic --catalog-name demo || true
run duck --host "$DUCK_HOST" --token "$DUCK_TOKEN" query execute --sql "SELECT COUNT(*) AS cnt FROM demo.titanic.passengers" || true

echo
echo "Retest complete."