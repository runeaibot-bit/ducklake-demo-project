# MovieLens Showcase

Flagship end-to-end showcase for DuckLake declarative workflows:

1. Load raw data through the ingestion API.
2. Transform with declarative models (bronze -> silver -> gold).
3. Reuse declarative macro logic.
4. Run notebook checks.
5. Trigger scheduled pipeline.
6. Demonstrate RBAC, row filters, and column masks.

## Directory layout

- `config/`: declarative resources (catalog, tables, security, governance, models, macros, notebooks, pipelines)
- `data/`: deterministic MovieLens seed set
- `scripts/`: local bootstrap and demo execution
- `assertions.yaml`: lifecycle expectations

## Quickstart

From repository root:

```bash
export DUCK_HOST="http://localhost:8080"
export DUCK_API_KEY="showcase-local-admin-key"

API_KEY="$DUCK_API_KEY" examples/showcase-movielens/scripts/bootstrap_admin_key.sh
DUCK_API_KEY="$DUCK_API_KEY" DUCK_HOST="$DUCK_HOST" examples/showcase-movielens/scripts/run_demo_flow.sh
```

## Optional manual flow

```bash
duck --host "$DUCK_HOST" --token '' --api-key "$DUCK_API_KEY" validate --config-dir examples/showcase-movielens/config
duck --host "$DUCK_HOST" --token '' --api-key "$DUCK_API_KEY" apply --config-dir examples/showcase-movielens/config --auto-approve
examples/showcase-movielens/scripts/ingest_seed_data.sh
```

## Troubleshooting

- Ensure metadata DB exists before bootstrap (`ducklake_meta.sqlite` in repo root).
- Ensure `duckdb` is installed so seed CSVs can be converted to parquet.
- If ingestion fails, verify `ducklake_data/showcase_ingest/*.parquet` exists after `ingest_seed_data.sh`.
