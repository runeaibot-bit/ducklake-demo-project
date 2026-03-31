# Examples

This directory mirrors the upstream product showcase layout.

## Flagship showcase

- `showcase-movielens`: ingestion API -> models (bronze/silver/gold) -> macro reuse -> notebook -> scheduled pipeline -> RBAC/RLS/column masking.

## Prerequisites

- Server running (default `http://localhost:8080`)
- `duck` CLI in `PATH`
- `duckdb` and `sqlite3`

## Fastest path

From repository root:

```bash
export DUCK_HOST="http://localhost:8080"
export DUCK_API_KEY="showcase-local-admin-key"

API_KEY="$DUCK_API_KEY" examples/showcase-movielens/scripts/bootstrap_admin_key.sh
DUCK_API_KEY="$DUCK_API_KEY" DUCK_HOST="$DUCK_HOST" examples/showcase-movielens/scripts/run_demo_flow.sh
```

See `examples/showcase-movielens/README.md` for full walkthrough.
