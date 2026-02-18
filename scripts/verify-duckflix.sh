#!/usr/bin/env bash
set -euo pipefail

# Verification for blueprint-aligned showcase outputs.

DUCK_HOST="${DUCK_HOST:-http://localhost:8080}"
DUCK_BIN="${DUCK_BIN:-duck}"
DUCK_API_KEY="${DUCK_API_KEY:-${API_KEY:-}}"

if [[ -z "$DUCK_API_KEY" ]]; then
  echo "ERROR: set DUCK_API_KEY or API_KEY" >&2
  exit 1
fi

if ! command -v "$DUCK_BIN" >/dev/null 2>&1; then
  echo "ERROR: duck CLI not found: $DUCK_BIN" >&2
  exit 1
fi

duck() {
  "$DUCK_BIN" --host "$DUCK_HOST" --token '' --api-key "$DUCK_API_KEY" "$@"
}

check_query() {
  local description="$1"
  local sql="$2"
  local result

  if ! result="$(duck query execute --sql "$sql")"; then
    echo "FAIL | $description | query failed"
    return 1
  fi

  if echo "$result" | grep -Eq '(^|[^A-Za-z0-9_])PASS([^A-Za-z0-9_]|$)'; then
    echo "PASS | $description"
    return 0
  fi

  echo "FAIL | $description"
  return 1
}

check_query "raw_movies loaded" "SELECT CASE WHEN (SELECT COUNT(*) FROM lake.main.raw_movies) > 0 THEN 'PASS' ELSE 'FAIL' END AS result"
check_query "raw_users loaded" "SELECT CASE WHEN (SELECT COUNT(*) FROM lake.main.raw_users) > 0 THEN 'PASS' ELSE 'FAIL' END AS result"
check_query "raw_ratings loaded" "SELECT CASE WHEN (SELECT COUNT(*) FROM lake.main.raw_ratings) > 0 THEN 'PASS' ELSE 'FAIL' END AS result"
check_query "gold_movie_scores built" "SELECT CASE WHEN (SELECT COUNT(*) FROM lake.main.gold_movie_scores) > 0 THEN 'PASS' ELSE 'FAIL' END AS result"
check_query "gold_user_engagement built" "SELECT CASE WHEN (SELECT COUNT(*) FROM lake.main.gold_user_engagement) > 0 THEN 'PASS' ELSE 'FAIL' END AS result"

echo "verify-duckflix.sh complete"
