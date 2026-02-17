#!/usr/bin/env bash
set -euo pipefail

# Load DuckFlix data into DuckLake using Duck CLI query execution.
#
# Usage:
#   DUCK_TOKEN="<jwt>" [DUCK_HOST="http://localhost:8080"] ./scripts/load-duckflix.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DATA_DIR="$PROJECT_ROOT/data/raw/movielens/ml-latest-small"

DUCK_HOST="${DUCK_HOST:-http://localhost:8080}"
DUCK_TOKEN="${DUCK_TOKEN:?DUCK_TOKEN env var must be set (no hardcoded secret allowed)}"

if ! command -v duck >/dev/null 2>&1; then
  echo "ERROR: 'duck' CLI not found in PATH" >&2
  exit 1
fi

for file in "$DATA_DIR/movies.csv" "$DATA_DIR/ratings.csv" "$DATA_DIR/tags.csv" "$DATA_DIR/links.csv"; do
  if [[ ! -f "$file" ]]; then
    echo "ERROR: missing required file: $file" >&2
    echo "Run ./scripts/fetch-movielens.sh first." >&2
    exit 1
  fi
done

run_duck() {
  duck --host "$DUCK_HOST" --token "$DUCK_TOKEN" "$@"
}

execute_sql() {
  local sql="$1"
  run_duck query execute --sql "$sql"
}

echo "Applying DuckFlix config..."
run_duck validate --config-dir "$PROJECT_ROOT/duck-config"
run_duck apply --config-dir "$PROJECT_ROOT/duck-config" --auto-approve --no-color

echo "Loading bronze tables..."
execute_sql "DELETE FROM demo.bronze.movies_raw"
execute_sql "INSERT INTO demo.bronze.movies_raw (movie_id, title, genres, source_file, ingested_at)
SELECT CAST(movieId AS BIGINT), title, genres, 'movies.csv', CURRENT_TIMESTAMP
FROM read_csv_auto('$DATA_DIR/movies.csv', header=true)"

execute_sql "DELETE FROM demo.bronze.ratings_raw"
execute_sql "INSERT INTO demo.bronze.ratings_raw (user_id, movie_id, rating, timestamp, ingested_at)
SELECT CAST(userId AS BIGINT), CAST(movieId AS BIGINT), CAST(rating AS DOUBLE), CAST(timestamp AS BIGINT), CURRENT_TIMESTAMP
FROM read_csv_auto('$DATA_DIR/ratings.csv', header=true)"

execute_sql "DELETE FROM demo.bronze.tags_raw"
execute_sql "INSERT INTO demo.bronze.tags_raw (user_id, movie_id, tag, timestamp, ingested_at)
SELECT CAST(userId AS BIGINT), CAST(movieId AS BIGINT), tag, CAST(timestamp AS BIGINT), CURRENT_TIMESTAMP
FROM read_csv_auto('$DATA_DIR/tags.csv', header=true)"

execute_sql "DELETE FROM demo.bronze.links_raw"
execute_sql "INSERT INTO demo.bronze.links_raw (movie_id, imdb_id, tmdb_id, ingested_at)
SELECT CAST(movieId AS BIGINT), CAST(imdbId AS BIGINT), CAST(tmdbId AS BIGINT), CURRENT_TIMESTAMP
FROM read_csv_auto('$DATA_DIR/links.csv', header=true)"

echo "Creating silver tables..."
execute_sql "DELETE FROM demo.silver.movies"
execute_sql "INSERT INTO demo.silver.movies (movie_id, title, release_year, genres)
SELECT
  movie_id,
  TRIM(REGEXP_EXTRACT(title, '^(.*)\\s*\\(\\d{4}\\)$', 1)),
  TRY_CAST(REGEXP_EXTRACT(title, '\\((\\d{4})\\)$', 1) AS BIGINT),
  genres
FROM demo.bronze.movies_raw"

execute_sql "DELETE FROM demo.silver.ratings"
execute_sql "INSERT INTO demo.silver.ratings (user_id, movie_id, rating, rating_ts)
SELECT user_id, movie_id, rating, TO_TIMESTAMP(timestamp)
FROM demo.bronze.ratings_raw"

execute_sql "DELETE FROM demo.silver.genres_bridge"
execute_sql "INSERT INTO demo.silver.genres_bridge (movie_id, genre)
SELECT
  m.movie_id,
  TRIM(g.value) AS genre
FROM demo.bronze.movies_raw m
CROSS JOIN UNNEST(string_split(COALESCE(m.genres, ''), '|')) AS g(value)
WHERE TRIM(g.value) <> '(no genres listed)' AND TRIM(g.value) <> ''"

echo "Creating gold tables..."
execute_sql "DELETE FROM demo.gold.mart_title_performance"
execute_sql "INSERT INTO demo.gold.mart_title_performance (movie_id, title, avg_rating, rating_count, last_refreshed_at)
SELECT
  r.movie_id,
  m.title,
  ROUND(AVG(r.rating), 3),
  COUNT(*),
  CURRENT_TIMESTAMP
FROM demo.silver.ratings r
LEFT JOIN demo.silver.movies m USING (movie_id)
GROUP BY r.movie_id, m.title"

execute_sql "DELETE FROM demo.gold.mart_genre_trends"
execute_sql "INSERT INTO demo.gold.mart_genre_trends (genre, month_bucket, avg_rating, active_users, last_refreshed_at)
SELECT
  g.genre,
  CAST(date_trunc('month', r.rating_ts) AS DATE) AS month_bucket,
  ROUND(AVG(r.rating), 3) AS avg_rating,
  COUNT(DISTINCT r.user_id) AS active_users,
  CURRENT_TIMESTAMP
FROM demo.silver.ratings r
JOIN demo.silver.genres_bridge g ON g.movie_id = r.movie_id
GROUP BY g.genre, month_bucket"

echo "DuckFlix load complete."