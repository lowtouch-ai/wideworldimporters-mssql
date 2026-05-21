#!/usr/bin/env bash
# Load exported SQL files into postgres_15.1 on the server.
# Run from repo root after copying the export/sql/ folder here.
#
# Usage:
#   bash scripts/load-export.sh
#   bash scripts/load-export.sh /path/to/export/sql   # custom folder

set -euo pipefail

CONTAINER=postgres_15.1
SQL_DIR="${1:-export/sql}"

if [ ! -d "$SQL_DIR" ]; then
  echo "ERROR: SQL export folder not found: $SQL_DIR"
  echo "Copy the export/sql/ folder from your local machine first."
  exit 1
fi

if ! docker inspect "$CONTAINER" --format '{{.State.Running}}' 2>/dev/null | grep -q true; then
  echo "ERROR: $CONTAINER is not running."
  exit 1
fi

echo "Loading exported SQL files into $CONTAINER..."
echo ""

total_files=$(ls "$SQL_DIR"/*.sql 2>/dev/null | wc -l)
count=0

for f in "$SQL_DIR"/*.sql; do
  [ -f "$f" ] || continue
  count=$((count + 1))
  echo -n "[$count/$total_files] $(basename $f) ... "
  result=$(docker exec -i "$CONTAINER" psql -U postgres -d postgres \
    --set ON_ERROR_STOP=1 -q 2>&1 < "$f")
  if [ $? -eq 0 ]; then
    echo "✓"
  else
    echo "✗"
    echo "$result" | head -10
    echo "Aborting — fix the error above and re-run."
    exit 1
  fi
done

echo ""
echo "Syncing sequences..."
docker exec -i "$CONTAINER" psql -U postgres -d postgres -q < postgres/fix_sequences.sql > /dev/null

echo ""
echo "=== Done. Row counts: ==="
docker exec "$CONTAINER" psql -U postgres -d postgres -c "
SELECT schemaname||'.'||tablename as table,
  (xpath('/row/cnt/text()',query_to_xml(
    'SELECT COUNT(*) AS cnt FROM '||schemaname||'.'||tablename,
    false,true,'')))[1]::text::int AS rows
FROM pg_tables
WHERE schemaname IN ('application','sales','purchasing','warehouse')
  AND tablename NOT LIKE '%archive%'
ORDER BY schemaname, tablename;" 2>/dev/null
