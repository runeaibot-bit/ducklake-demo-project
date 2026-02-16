# Dogfood Log — 2026-02-16

## Context
- Server: `http://localhost:8080`
- CLI: `/root/.openclaw/workspace/ducklake-dataplatform/bin/duck`
- Demo config: `/root/.openclaw/workspace/ducklake-demo-project/duck-config`

## Actions
- Verified server process listening on `:8080`.
- Verified server runtime includes:
  - `JWT_SECRET=dev-secret-change-in-production`
- Ran command-tour smoke tests across top-level command groups:
  - `catalog`, `security`, `query`, `describe`, `find`, `export`, `governance`,
    `lineage`, `compute`, `storage`, `ingestion`, `notebooks`, `pipelines`,
    `observability`, `manifest`, `validate`, `plan`, `apply`.
- Used valid/invalid command inputs and edge-ish error paths.

## Bugs filed
- https://github.com/Yacobolo/ducklake-dataplatform/issues/171
  - `duck query execute --help` shows non-working example (`duck query --sql`)
- https://github.com/Yacobolo/ducklake-dataplatform/issues/172
  - Unknown `duck security` subcommand exits with status `0`
- https://github.com/Yacobolo/ducklake-dataplatform/issues/173
  - `duck auth token --admin` token still gets 403 on admin-only endpoints

## Running tally
- New bugs filed this run: **3**
- Prior known bugs (from earlier sessions): **4**
- Total known bugs so far: **7**
