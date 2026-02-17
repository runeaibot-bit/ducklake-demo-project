# DuckLake Demo Project — Titanic Analytics

A demo data project built with the [DuckDB Data Platform](https://github.com/Yacobolo/ducklake-dataplatform), showcasing terraform-style declarative configuration for data governance.

## What this demonstrates

- **Declarative config** — all schemas, tables, principals, groups, grants, and security policies are defined in YAML and version-controlled
- **RBAC** — role-based access control with principals and groups
- **Row-Level Security** — analysts can only see passenger data for their assigned class
- **Column Masking** — PII fields (names, ticket numbers) are masked for non-admin users
- **Audit Trail** — all access is logged

## Project Structure

```
duck-config/
├── catalogs.yaml          # DuckLake catalog registration
├── schemas.yaml           # Schema definitions
├── principals.yaml        # User identities
├── groups.yaml            # Role groups (admin, analyst, viewer)
├── grants.yaml            # Permission grants per group
├── row_filters.yaml       # Row-level security policies
└── column_masks.yaml      # Column masking rules
```

## Usage

```bash
# Validate configuration
duck validate --config-dir duck-config

# Preview changes (terraform plan)
duck plan --config-dir duck-config

# Apply changes (terraform apply)
duck apply --config-dir duck-config --auto-approve

# Export current state
duck export --config-dir duck-config

# One-shot retest helper (validate + plan + apply + checks)
./scripts/retest-demo.sh
```

## Known Current Blockers (platform-side)

At the moment this demo is partially blocked by open platform bugs in `Yacobolo/ducklake-dataplatform`:

- **#147**: query path cannot resolve table after apply
  - `duck query execute --sql "SELECT COUNT(*) AS cnt FROM demo.titanic.passengers"`
  - fails with: `catalog lookup: table "passengers" not found in catalog`
- **#196**: column-mask apply can report `resource already exists` and then fail binding lookup in the same apply run
  - `create column-mask ".../mask-name" ... API error (HTTP 500): resource already exists`
  - `create column-mask-binding ".../mask-name->group:viewers" ... column mask ... not found in index`

The config in this repo is valid (`duck validate` passes), but full end-to-end apply+query success depends on those upstream fixes landing.

## Requirements

- [DuckDB Data Platform](https://github.com/Yacobolo/ducklake-dataplatform) server running
- `duck` CLI binary
