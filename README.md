# ducklake-demo-project

Blueprint-aligned demo repo based on:
`Yacobolo/ducklake-dataplatform/examples/showcase-movielens`

## Primary entrypoint

Use the canonical showcase under:

- `examples/showcase-movielens/`

This includes declarative config, seed data, and runnable scripts for:

- ingestion API loading
- bronze/silver/gold model runs
- notebook + pipeline execution
- RBAC / row filters / column masking example resources

## Quickstart

Prereqs:

- DuckLake server running
- `duck` CLI available in `PATH`
- `duckdb` + `sqlite3` installed

Then from repo root:

```bash
export DUCK_HOST="http://localhost:8080"
export DUCK_API_KEY="showcase-local-admin-key"

# one-time bootstrap of admin key in metadata sqlite
# set META_DB if your server metadata file is elsewhere
API_KEY="$DUCK_API_KEY" META_DB="${META_DB:-./ducklake_meta.sqlite}" \
  examples/showcase-movielens/scripts/bootstrap_admin_key.sh

# full showcase flow
DUCK_API_KEY="$DUCK_API_KEY" DUCK_HOST="$DUCK_HOST" \
  examples/showcase-movielens/scripts/run_demo_flow.sh
```

## Compatibility wrappers

Top-level scripts remain for convenience and now delegate to the canonical showcase flow where relevant:

- `scripts/load-duckflix.sh`
- `scripts/verify-duckflix.sh`
- `scripts/nightly_demo_check.sh` (validate/plan/apply + query smoke checks, writes logs to `.artifacts/nightly/`)

## Troubleshooting

If `scripts/nightly_demo_check.sh` fails with an API-unreachable error, verify the local DuckLake server first:

```bash
curl -f http://localhost:8080/healthz
```

Known platform blockers:
- API unreachable / server build drift on main: <https://github.com/Yacobolo/ducklake-dataplatform/issues/231>
- Declarative apply fails on models (`resource kind not yet implemented`): <https://github.com/Yacobolo/ducklake-dataplatform/issues/257>

## Source blueprint

- <https://github.com/Yacobolo/ducklake-dataplatform/tree/main/examples>
