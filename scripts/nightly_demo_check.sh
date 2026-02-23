#!/usr/bin/env bash
set -euo pipefail

# End-to-end nightly smoke for the showcase demo.
# Runs validate/plan/apply and basic read/query checks.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

export DUCK_HOST="${DUCK_HOST:-http://localhost:8080}"
export DUCK_API_KEY="${DUCK_API_KEY:-showcase-local-admin-key}"
export META_DB="${META_DB:-$ROOT_DIR/ducklake_meta.sqlite}"

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

  DUCK_API_KEY="$DUCK_API_KEY" DUCK_HOST="$DUCK_HOST" \
    examples/showcase-movielens/scripts/run_demo_flow.sh

  echo "[nightly] read/query checks"
  duck --host "$DUCK_HOST" --token '' --api-key "$DUCK_API_KEY" \
    query execute --sql "SELECT COUNT(*) AS c FROM lake.main.gold_user_engagement"
  duck --host "$DUCK_HOST" --token '' --api-key "$DUCK_API_KEY" \
    query execute --sql "SELECT user_id, avg_rating_given FROM lake.main.gold_user_engagement ORDER BY avg_rating_given DESC LIMIT 5"
} 2>&1 | tee "$log"

echo "[nightly] log: $log"