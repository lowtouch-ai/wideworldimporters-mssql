#!/usr/bin/env bash
# fix-sequences.sh — Reset all PostgreSQL sequences to match migrated data
#
# After migrating data from SQL Server to PostgreSQL, sequence counters
# (auto-ID dispensers) are left at their initial values and do not know
# about the IDs already present in the migrated rows. This causes duplicate-key
# errors on the first INSERT into any affected table.
#
# This script resets every sequence to MAX(id) so new inserts get IDs that
# are safely above all existing rows.
#
# Usage:
#   bash scripts/fix-sequences.sh
#
# Environment variables (all optional — defaults match the Docker dev setup):
#   PG_HOST      PostgreSQL host         (default: resolved from postgres_15.1 container)
#   PG_PORT      PostgreSQL port         (default: 5432)
#   PG_USER      PostgreSQL user         (default: postgres)
#   PG_PASSWORD  PostgreSQL password     (default: postgres)
#   PG_DB        Database name           (default: wideworldimporters)
#
# Prerequisites:
#   - psql available, OR the postgres_15.1 Docker container is running
#
# Exit code: 0 = success, 1 = connection or execution error

set -euo pipefail

# ── Resolve connection details ────────────────────────────────────────────────

PG_PORT="${PG_PORT:-5432}"
PG_USER="${PG_USER:-postgres}"
PG_PASSWORD="${PG_PASSWORD:-postgres}"
PG_DB="${PG_DB:-wideworldimporters}"

if [ -z "${PG_HOST:-}" ]; then
    echo "PG_HOST not set — resolving from postgres_15.1 Docker container..."
    PG_HOST=$(docker inspect postgres_15.1 \
        --format '{{(index .NetworkSettings.Networks "appz-images_agentomatic_net").IPAddress}}' \
        2>/dev/null || true)
    if [ -z "$PG_HOST" ]; then
        PG_HOST=$(docker inspect postgres_15.1 \
            --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
            2>/dev/null | head -1 || true)
    fi
    if [ -z "$PG_HOST" ]; then
        echo "ERROR: Could not resolve postgres_15.1 container IP. Set PG_HOST manually." >&2
        exit 1
    fi
    echo "  Resolved PG_HOST=$PG_HOST"
fi

export PGPASSWORD="$PG_PASSWORD"

echo ""
echo "Resetting sequences on $PG_HOST:$PG_PORT/$PG_DB ..."
echo ""

# ── SQL: reset all sequences to MAX(id) of their table ───────────────────────

psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -d "$PG_DB" -v ON_ERROR_STOP=1 <<'SQL'

DO $$
DECLARE
    r       RECORD;
    max_val BIGINT;
    seq_name TEXT;
BEGIN
    FOR r IN
        SELECT
            n.nspname  AS schema_name,
            t.relname  AS table_name,
            a.attname  AS col_name,
            pg_get_serial_sequence(
                n.nspname || '.' || t.relname, a.attname
            )          AS seq
        FROM pg_attribute a
        JOIN pg_class     t ON a.attrelid = t.oid
        JOIN pg_namespace n ON t.relnamespace = n.oid
        WHERE a.attnum > 0
          AND NOT a.attisdropped
          AND pg_get_serial_sequence(
                  n.nspname || '.' || t.relname, a.attname
              ) IS NOT NULL
        ORDER BY n.nspname, t.relname
    LOOP
        EXECUTE format(
            'SELECT MAX(%I) FROM %I.%I',
            r.col_name, r.schema_name, r.table_name
        ) INTO max_val;

        IF max_val IS NOT NULL THEN
            PERFORM setval(r.seq, max_val);
            RAISE NOTICE 'Reset %.%: seq → %',
                r.schema_name, r.table_name, max_val;
        END IF;
    END LOOP;

    RAISE NOTICE 'Done. All sequences are now in sync with migrated data.';
END $$;

SQL

echo ""
echo "Sequence reset complete."
