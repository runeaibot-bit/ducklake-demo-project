#!/usr/bin/env bash
set -euo pipefail

# Fetch MovieLens small dataset for DuckFlix.
#
# Usage:
#   ./scripts/fetch-movielens.sh
#
# What it does:
#   - Creates data/raw/movielens under the project root
#   - Downloads ml-latest-small.zip from GroupLens if missing or corrupted
#   - Unzips dataset if not already extracted
#
# Notes:
#   - Safe to rerun (idempotent)
#   - No secrets are used

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RAW_DIR="$PROJECT_ROOT/data/raw/movielens"
ZIP_PATH="$RAW_DIR/ml-latest-small.zip"
UNPACKED_DIR="$RAW_DIR/ml-latest-small"
DATASET_URL="https://files.grouplens.org/datasets/movielens/ml-latest-small.zip"

mkdir -p "$RAW_DIR"

zip_valid() {
  python3 - "$1" <<'PY'
import sys, zipfile
p = sys.argv[1]
try:
    with zipfile.ZipFile(p) as zf:
        bad = zf.testzip()
        if bad is not None:
            raise RuntimeError(bad)
    print("ok")
except Exception:
    sys.exit(1)
PY
}

need_download=false
if [[ ! -s "$ZIP_PATH" ]]; then
  need_download=true
else
  if ! zip_valid "$ZIP_PATH" >/dev/null 2>&1; then
    need_download=true
  fi
fi

if [[ "$need_download" == true ]]; then
  echo "Downloading MovieLens dataset..."
  curl -fL --retry 3 --retry-delay 2 -o "$ZIP_PATH" "$DATASET_URL"
else
  echo "Using cached archive: $ZIP_PATH"
fi

if ! zip_valid "$ZIP_PATH" >/dev/null 2>&1; then
  echo "ERROR: ZIP file is invalid: $ZIP_PATH" >&2
  exit 1
fi

if [[ ! -d "$UNPACKED_DIR" ]] || [[ ! -f "$UNPACKED_DIR/movies.csv" ]] || [[ ! -f "$UNPACKED_DIR/ratings.csv" ]] || [[ ! -f "$UNPACKED_DIR/tags.csv" ]] || [[ ! -f "$UNPACKED_DIR/links.csv" ]]; then
  echo "Extracting MovieLens dataset..."
  python3 - "$ZIP_PATH" "$RAW_DIR" <<'PY'
import sys, zipfile
zip_path, out_dir = sys.argv[1], sys.argv[2]
with zipfile.ZipFile(zip_path) as zf:
    zf.extractall(out_dir)
print("extracted")
PY
else
  echo "Raw files already extracted."
fi

# Optional quick validation for expected files
required=(movies.csv ratings.csv tags.csv links.csv)
for file in "${required[@]}"; do
  if [[ -f "$UNPACKED_DIR/$file" ]]; then
    echo "OK: $UNPACKED_DIR/$file"
  else
    echo "ERROR: missing $file in $UNPACKED_DIR" >&2
    exit 1
  fi
done

echo "MovieLens dataset is ready in: $UNPACKED_DIR"