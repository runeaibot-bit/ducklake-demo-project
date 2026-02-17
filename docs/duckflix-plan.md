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

## Immediate Next Steps
1. Add DuckFlix directory structure under duck-config/catalogs/demo/schemas/
2. Add schema and table YAMLs for bronze/silver/gold core tables
3. Add security principals/groups/grants for DuckFlix roles
4. Add row filter + column mask examples on ratings/user fields
5. Add scripts:
   - scripts/fetch-movielens.sh
   - scripts/load-duckflix.sh
   - scripts/verify-duckflix.sh
6. Update README with DuckFlix quickstart and expected query outputs
