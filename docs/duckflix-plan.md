# DuckFlix Analytics — Implementation Plan

## Theme
Movie analytics showcase using MovieLens (+ optional IMDb enrichment).

## Goals
- Be instantly understandable to non-technical audiences
- Exercise complex joins (many-to-many cast/genre/title/user-rating)
- Showcase platform governance: RBAC, row filters, column masking, tags
- Stay script-first for reproducible bug-hunting and demo reset

## Data Layers

### Bronze (raw)
- bronze.movies_raw
- bronze.ratings_raw
- bronze.tags_raw
- bronze.links_raw
- bronze.people_raw (optional IMDb)
- bronze.title_principals_raw (optional IMDb)

### Silver (cleaned/conformed)
- silver.movies
- silver.users
- silver.ratings
- silver.genres_bridge
- silver.tags
- silver.people (optional)
- silver.title_cast_bridge (optional)

### Gold (business marts)
- gold.mart_title_performance
- gold.mart_genre_trends
- gold.mart_user_taste_segments
- gold.mart_recommendation_candidates

## Security/Governance Demo
- Roles: admin, content_analyst, marketing_analyst, viewer
- Column masking: user_id hashing/masking for non-admins
- Row filters: cohort/date or region segment constraints
- Tags: pii, internal, public, recommendation_feature

## Current Blocker (2026-02-18)
- End-to-end retest is currently blocked at `duck plan`/`duck apply` with local dev auth returning HTTP 401.
- Repro path: `./scripts/retest-demo.sh` (validate passes; plan/apply fail with unauthorized).
- Tracked in platform repo: https://github.com/Yacobolo/ducklake-dataplatform/issues/215

## Immediate Next Steps
1. Unblock local dev auth in platform (issue #215) or run demo via API key/OIDC-enabled environment.
2. Once unblocked, rerun `./scripts/retest-demo.sh` and continue silver/gold verification.
3. Extend demo docs with before/after screenshots and expected query outputs for non-technical walkthrough.
