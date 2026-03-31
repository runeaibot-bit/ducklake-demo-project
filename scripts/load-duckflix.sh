#!/usr/bin/env bash
set -euo pipefail

# Compatibility wrapper: run canonical showcase flow.
# Preferred entrypoint:
#   examples/showcase-movielens/scripts/run_demo_flow.sh

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -z "${DUCK_API_KEY:-}" && -z "${API_KEY:-}" ]]; then
  echo "ERROR: set DUCK_API_KEY or API_KEY" >&2
  exit 1
fi

exec "$ROOT_DIR/examples/showcase-movielens/scripts/run_demo_flow.sh"
