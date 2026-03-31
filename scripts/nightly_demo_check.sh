#!/usr/bin/env bash
set -euo pipefail

# End-to-end nightly smoke for the showcase demo.
# Runs validate/plan/apply and basic read/query checks.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

export DUCK_HOST="${DUCK_HOST:-http://localhost:8080}"
export DUCK_API_KEY="${DUCK_API_KEY:-showcase-local-admin-key}"
export META_DB="${META_DB:-$ROOT_DIR/ducklake_meta.sqlite}"

# If a DuckLake server is already running, prefer its configured metadata DB.
# This avoids bootstrap/auth mismatches when server state lives outside repo root.
if [[ -z "${META_DB_OVERRIDE:-}" ]]; then
  server_pid="$(ss -ltnp 2>/dev/null | awk '/:8080/ {print $NF}' | sed -E 's/.*pid=([0-9]+).*/\1/' | head -n1 || true)"
  if [[ -n "$server_pid" && -r "/proc/$server_pid/environ" ]]; then
    server_meta_db="$(tr '\0' '\n' < "/proc/$server_pid/environ" | awk -F= '/^META_DB_PATH=/{print $2}' | head -n1 || true)"
    if [[ -n "$server_meta_db" && -f "$server_meta_db" ]]; then
      META_DB="$server_meta_db"
    fi
  fi
fi

mkdir -p .artifacts/nightly
stamp="$(date -u +%Y%m%dT%H%M%SZ)"
log=".artifacts/nightly/demo-flow-${stamp}.log"

{
  echo "[nightly] stamp=$stamp"
  echo "[nightly] host=$DUCK_HOST"
  echo "[nightly] meta_db=$META_DB"

  if [[ ! -f "$META_DB" ]]; then
    fallback="/root/.openclaw/workspace/ducklake_meta.sqlite"
    if [[ -f "$fallback" ]]; then
      export META_DB="$fallback"
      echo "[nightly] using fallback META_DB=$META_DB"
    else
      echo "[nightly] metadata DB missing: $META_DB"
      exit 1
    fi
  fi

  API_KEY="$DUCK_API_KEY" META_DB="$META_DB" \
    examples/showcase-movielens/scripts/bootstrap_admin_key.sh

  if ! curl -fsS "$DUCK_HOST/healthz" >/dev/null 2>&1; then
    echo "[nightly] blocker: DuckLake API unreachable at $DUCK_HOST"
    echo "[nightly] likely known platform blocker:"
    echo "[nightly] https://github.com/Yacobolo/ducklake-dataplatform/issues/231"
    exit 1
  fi

  DUCK_API_KEY="$DUCK_API_KEY" DUCK_HOST="$DUCK_HOST" \
    examples/showcase-movielens/scripts/run_demo_flow.sh

  echo "[nightly] read/query checks"
  duck --host "$DUCK_HOST" --token '' --api-key "$DUCK_API_KEY" \
    query execute --sql "SELECT COUNT(*) AS c FROM lake.main.gold_user_engagement"
  duck --host "$DUCK_HOST" --token '' --api-key "$DUCK_API_KEY" \
    query execute --sql "SELECT user_id, avg_rating_given FROM lake.main.gold_user_engagement ORDER BY avg_rating_given DESC LIMIT 5"
} 2>&1 | tee "$log"

echo "[nightly] log: $log"