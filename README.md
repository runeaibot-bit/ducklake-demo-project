# DuckFlix Demo Project

A short, script-first DuckLake demo using the **MovieLens** dataset. It applies DuckDB governance config (schemas, roles, grants, row filters, and masking) and demonstrates an end-to-end movie analytics workflow.

## What this demonstrates

- End-to-end **declarative** DuckDB governance setup for a real analytics use case.
- Practical **layered architecture** with Bronze → Silver → Gold tables.
- Reproducible, script-driven flow for fetching raw source data, loading cataloged tables, and validating results.
- Security controls including **RBAC**, **row-level filters**, and **column masking**.

## Architecture (bronze / silver / gold)

- **bronze**
  - `bronze.movies_raw`
  - `bronze.ratings_raw`
  - `bronze.tags_raw`
  - `bronze.links_raw`
- **silver**
  - `silver.movies`
  - `silver.ratings`
  - `silver.tags`
  - `silver.genres_bridge`
- **gold**
  - `gold.mart_title_performance`
  - `gold.mart_genre_trends`
  - `gold.mart_user_taste_segments`
  - `gold.mart_recommendation_candidates`

## Quickstart

1. **Fetch the source data**
   ```bash
   ./scripts/fetch-movielens.sh
   ```

2. **Apply governance configuration**
   ```bash
   duck validate --config-dir duck-config
   duck plan --config-dir duck-config
   duck apply --config-dir duck-config --auto-approve
   ```

3. **Load DuckFlix data**
   ```bash
   ./scripts/load-duckflix.sh
   ```

4. **Verify tables / queries / security expectations**
   ```bash
   ./scripts/verify-duckflix.sh
   ```

## Example business questions

- Which movie genres are trending over time?
- Which titles have the highest conversion from short to repeat ratings?
- Which users are high-volume raters in specific cohorts?
- Which segments have the strongest recommendation signal by genre?
- Are any PII-like user fields hidden for non-admin roles?

## Known blockers

- **#147**: Query path issues can still appear after apply in some platform states (for example, catalog/table resolution timing can fail when querying `demo.duckflix` objects immediately).
- **#196**: Column-mask creation and mask-binding application may intermittently hit `resource already exists` semantics and block a clean single-run apply.

The repo configuration is still valid and passes standard validation, but a fully clean apply + immediate query cycle may depend on upstream fixes in `Yacobolo/ducklake-dataplatform`.