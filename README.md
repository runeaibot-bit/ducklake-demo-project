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
```

## Requirements

- [DuckDB Data Platform](https://github.com/Yacobolo/ducklake-dataplatform) server running
- `duck` CLI binary
