#!/usr/bin/env python3
"""
test_migration_full.py — 6-tier live database verification: MSSQL → PostgreSQL

  T1  Table inventory  (discovers tables dynamically — no hardcoded list)
  T2  Row count parity
  T3  Column aggregate checksums  (SUM / LEN / DISTINCT / MIN-MAX / BIT_TRUES / NULLs)
  T4  Sample row spot-check  (20 random rows per table, field-by-field comparison)
  T5  Referential integrity  (FK orphan check: uses MSSQL FK definitions, checks PG data)
  T6  Sequence alignment  (last_value >= MAX(pk) for all sequences)

Known-drift tables (post-migration API writes) are flagged WARN not FAIL.
Geography / binary columns are intentionally NULL in PG — verified, not failed.
"""
import os
import sys
import json
import subprocess
import datetime
import decimal
import time
from collections import defaultdict

import pymssql
import psycopg2

# ─────────────────────────────────────────────────────────────────────────────
# Connection — uses docker inspect for IP resolution; override with env vars
# ─────────────────────────────────────────────────────────────────────────────

def _docker_ip(container, network=None):
    out = subprocess.check_output(
        ["docker", "inspect", container], stderr=subprocess.DEVNULL)
    info = json.loads(out)
    nets = info[0]["NetworkSettings"]["Networks"]
    if network and network in nets:
        return nets[network]["IPAddress"]
    return next(iter(nets.values()))["IPAddress"]

MSSQL_HOST = os.getenv("MSSQL_HOST") or _docker_ip("mssql_wwi")
PG_HOST    = (os.getenv("PG_HOST") or
              _docker_ip("postgres_15.1", "appz-images_agentomatic_net"))

MSSQL_CFG = dict(
    server   = MSSQL_HOST,
    port     = int(os.getenv("MSSQL_PORT", 1433)),
    user     = os.getenv("MSSQL_USER", "sa"),
    password = os.getenv("MSSQL_PASS", "Sp1d3rman!"),
    database = os.getenv("MSSQL_DB",   "WideWorldImporters"),
)
PG_CFG = dict(
    host     = PG_HOST,
    port     = int(os.getenv("PG_PORT", 5432)),
    user     = os.getenv("PG_USER",   "postgres"),
    password = os.getenv("PG_PASS",   "postgres"),
    dbname   = os.getenv("PG_DB",     "wideworldimporters"),
)

# ─────────────────────────────────────────────────────────────────────────────
# Scope
# ─────────────────────────────────────────────────────────────────────────────

MSSQL_SCHEMAS = frozenset({
    "Application", "Warehouse", "Purchasing", "Sales",
    "DataLoadSimulation", "Website", "Integration",
})

# Tables whose PG data is expected to diverge from MSSQL due to post-migration
# API writes.  Row-count mismatches and checksum diffs are WARN (not FAIL).
KNOWN_DRIFT = frozenset({
    "application.people",
    "application.cities",
    "warehouse.packagetypes",
    "warehouse.stockitems",
    "sales.buyinggroups",
    "sales.customercategories",
    "sales.customers",
    "sales.invoices",
    "sales.customertransactions",
})

# ─────────────────────────────────────────────────────────────────────────────
# Type constants
# ─────────────────────────────────────────────────────────────────────────────

NUMERIC_TYPES = frozenset({
    "int", "bigint", "smallint", "tinyint",
    "decimal", "numeric", "money", "smallmoney", "float", "real",
})
APPROX_TYPES = frozenset({"float", "real"})
STRING_TYPES = frozenset({"nvarchar", "varchar", "nchar", "char", "ntext", "text"})
DATE_TYPES   = frozenset({"date", "datetime", "datetime2", "smalldatetime", "datetimeoffset"})
BIT_TYPES    = frozenset({"bit"})
# Geography / binary / rowversion intentionally migrated as NULL — skip checksums
SKIP_TYPES   = frozenset({
    "geography", "varbinary", "binary", "image",
    "rowversion", "timestamp", "hierarchyid", "xml",
})

REL_TOL_EXACT  = 1e-9
REL_TOL_APPROX = 1e-4
SPOT_SAMPLE    = 20   # random rows to spot-check per table

# ─────────────────────────────────────────────────────────────────────────────
# Output / state
# ─────────────────────────────────────────────────────────────────────────────

_report     = []   # all lines emitted (goes into the markdown report)
_counts     = {"PASS": 0, "FAIL": 0, "WARN": 0, "SKIP": 0}
_fail_lines = []   # summary of every FAIL line (shown in report header)


def emit(line=""):
    print(line, flush=True)
    _report.append(line)


def record(label, subject, detail=None):
    icon = {"PASS": "✓", "FAIL": "✗", "WARN": "⚠", "SKIP": "–", "INFO": " "}.get(label, " ")
    if label in _counts:
        _counts[label] += 1
    body = f"  {icon} [{label:4s}] {subject}"
    if detail:
        body += f"  —  {detail}"
    emit(body)
    if label == "FAIL":
        _fail_lines.append(body.strip())


def scalar(cur, sql, params=None):
    cur.execute(sql, params or ())
    row = cur.fetchone()
    return row[0] if row else None


def floats_close(a, b, tol):
    if a is None and b is None:
        return True
    if a is None or b is None:
        return False
    denom = max(abs(float(a)), abs(float(b)), 1.0)
    return abs(float(a) - float(b)) / denom < tol


def fmt(n):
    return f"{n:,}" if n is not None else "—"


# ─────────────────────────────────────────────────────────────────────────────
# Tier 1 — Table Inventory
# ─────────────────────────────────────────────────────────────────────────────

def tier1_inventory(ms_cur, pg_cur):
    emit("\n## Tier 1 — Table Inventory")

    schema_list = ", ".join(f"'{s}'" for s in MSSQL_SCHEMAS)
    ms_cur.execute(f"""
        SELECT LOWER(TABLE_SCHEMA), LOWER(TABLE_NAME)
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_TYPE = 'BASE TABLE'
          AND TABLE_SCHEMA IN ({schema_list})
        ORDER BY 1, 2
    """)
    mssql_tables = {f"{r[0]}.{r[1]}" for r in ms_cur.fetchall()}

    pg_cur.execute("""
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_type = 'BASE TABLE'
          AND table_schema NOT IN
              ('pg_catalog', 'information_schema', 'wwi_test', 'public', 'sequences')
        ORDER BY 1, 2
    """)
    pg_tables = {f"{r[0]}.{r[1]}" for r in pg_cur.fetchall()}

    emit(f"  MSSQL: {len(mssql_tables)} tables   PG: {len(pg_tables)} tables")

    missing_in_pg = mssql_tables - pg_tables
    extra_in_pg   = pg_tables   - mssql_tables
    matched       = mssql_tables & pg_tables

    archive_missing     = {t for t in missing_in_pg if "_archive" in t}
    non_archive_missing = missing_in_pg - archive_missing

    for t in sorted(non_archive_missing):
        record("FAIL", f"Table missing in PG: {t}")
    for t in sorted(archive_missing):
        record("WARN", f"Archive table not ported to PG (temporal table stripped): {t}")
    for t in sorted(extra_in_pg):
        record("WARN", f"Extra table in PG not in MSSQL scope: {t}")

    if not non_archive_missing and not extra_in_pg:
        note = (f"  ({len(archive_missing)} archive tables excluded — "
                "temporal stripping by design)" if archive_missing else "")
        record("PASS",
               f"All {len(matched)} non-archive tables present in both databases{note}")
    else:
        emit(f"  Matched: {len(matched)}  "
             f"Missing (non-archive): {len(non_archive_missing)}  "
             f"Archive gaps: {len(archive_missing)}  "
             f"Extra in PG: {len(extra_in_pg)}")

    return frozenset(matched)


# ─────────────────────────────────────────────────────────────────────────────
# Tier 2 — Row Count Comparison
# ─────────────────────────────────────────────────────────────────────────────

def tier2_row_counts(ms_cur, pg_cur, matched):
    emit("\n## Tier 2 — Row Count Comparison")
    fails = 0
    for tbl in sorted(matched):
        schema, table = tbl.split(".", 1)
        try:
            ms_cnt = scalar(ms_cur, f"SELECT COUNT(*) FROM [{schema}].[{table}]")
            pg_cnt = scalar(pg_cur, f"SELECT COUNT(*) FROM {tbl}")
            delta  = (pg_cnt or 0) - (ms_cnt or 0)
            if delta == 0:
                record("PASS", tbl, f"{fmt(ms_cnt)} rows")
            elif tbl in KNOWN_DRIFT:
                record("WARN", tbl,
                       f"MSSQL={fmt(ms_cnt)}  PG={fmt(pg_cnt)}  Δ={delta:+d}  (known API drift)")
            else:
                record("FAIL", tbl,
                       f"MSSQL={fmt(ms_cnt)}  PG={fmt(pg_cnt)}  Δ={delta:+d}")
                fails += 1
        except Exception as exc:
            record("FAIL", tbl, f"error: {exc}")
            fails += 1
    return fails


# ─────────────────────────────────────────────────────────────────────────────
# Tier 3 — Column Aggregate Checksums
# ─────────────────────────────────────────────────────────────────────────────

def _col_checks(ms_cur, pg_cur, schema, table, tbl):
    """Return (failures, warnings) as lists of description strings."""
    ms_cur.execute("""
        SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = %s AND TABLE_NAME = %s
        ORDER BY ORDINAL_POSITION
    """, (schema, table))
    columns = [(r[0], r[1].lower(), r[2]) for r in ms_cur.fetchall()]

    fails, warns = [], []

    for col_name, dtype, nullable in columns:
        col_pg = col_name.lower()

        if dtype in SKIP_TYPES:
            # Geography/binary: must be all-NULL in PG (migrated as NULL by design)
            try:
                nonnull = scalar(pg_cur,
                    f"SELECT COUNT(*) FROM {tbl} WHERE {col_pg} IS NOT NULL")
                if nonnull and nonnull > 0:
                    warns.append(
                        f"{col_name} ({dtype}): expected all-NULL in PG "
                        f"but {nonnull} non-NULL rows found")
            except Exception:
                pass  # column missing in PG — Tier 1 would have caught it
            continue

        try:
            if dtype in NUMERIC_TYPES:
                cast = "FLOAT" if dtype in APPROX_TYPES else "DECIMAL(38,10)"
                tol  = REL_TOL_APPROX if dtype in APPROX_TYPES else REL_TOL_EXACT
                ms_s = scalar(ms_cur,
                    f"SELECT CAST(SUM(CAST([{col_name}] AS {cast})) AS FLOAT) "
                    f"FROM [{schema}].[{table}]")
                pg_s = scalar(pg_cur,
                    f"SELECT SUM({col_pg}::numeric)::float8 FROM {tbl}")
                if not floats_close(ms_s, pg_s, tol):
                    fails.append(f"SUM({col_name}): MSSQL={ms_s}  PG={pg_s}")

            elif dtype in STRING_TYPES:
                ms_l = scalar(ms_cur,
                    f"SELECT SUM(LEN(CAST([{col_name}] AS NVARCHAR(MAX)))) "
                    f"FROM [{schema}].[{table}]")
                pg_l = scalar(pg_cur,
                    f"SELECT SUM(LENGTH({col_pg}::text)) FROM {tbl}")
                if ms_l != pg_l:
                    fails.append(f"LEN({col_name}): MSSQL={fmt(ms_l)}  PG={fmt(pg_l)}")

                ms_d = scalar(ms_cur,
                    f"SELECT COUNT(DISTINCT [{col_name}]) FROM [{schema}].[{table}]")
                pg_d = scalar(pg_cur,
                    f"SELECT COUNT(DISTINCT {col_pg}) FROM {tbl}")
                if ms_d != pg_d:
                    fails.append(
                        f"DISTINCT({col_name}): MSSQL={fmt(ms_d)}  PG={fmt(pg_d)}")

            elif dtype in DATE_TYPES:
                ms_mn = str(scalar(ms_cur,
                    f"SELECT MIN([{col_name}]) FROM [{schema}].[{table}]") or "")[:19]
                ms_mx = str(scalar(ms_cur,
                    f"SELECT MAX([{col_name}]) FROM [{schema}].[{table}]") or "")[:19]
                pg_mn = str(scalar(pg_cur,
                    f"SELECT MIN({col_pg}) FROM {tbl}") or "")[:19]
                pg_mx = str(scalar(pg_cur,
                    f"SELECT MAX({col_pg}) FROM {tbl}") or "")[:19]
                if ms_mn != pg_mn or ms_mx != pg_mx:
                    fails.append(
                        f"RANGE({col_name}): MSSQL=[{ms_mn}, {ms_mx}]  "
                        f"PG=[{pg_mn}, {pg_mx}]")

            elif dtype in BIT_TYPES:
                ms_t = scalar(ms_cur,
                    f"SELECT SUM(CAST([{col_name}] AS INT)) FROM [{schema}].[{table}]")
                pg_t = scalar(pg_cur,
                    f"SELECT SUM({col_pg}::int) FROM {tbl}")
                if ms_t != pg_t:
                    fails.append(
                        f"BIT_TRUES({col_name}): MSSQL={fmt(ms_t)}  PG={fmt(pg_t)}")

        except Exception as exc:
            warns.append(f"{col_name}: checksum error — {exc}")

        # NULL distribution (for any nullable column regardless of type)
        if nullable == "YES":
            try:
                ms_n = scalar(ms_cur,
                    f"SELECT SUM(CASE WHEN [{col_name}] IS NULL THEN 1 ELSE 0 END) "
                    f"FROM [{schema}].[{table}]")
                pg_n = scalar(pg_cur,
                    f"SELECT SUM(CASE WHEN {col_pg} IS NULL THEN 1 ELSE 0 END) "
                    f"FROM {tbl}")
                if ms_n != pg_n:
                    fails.append(
                        f"NULLS({col_name}): MSSQL={fmt(ms_n)}  PG={fmt(pg_n)}")
            except Exception as exc:
                warns.append(f"{col_name}: NULL check error — {exc}")

    return fails, warns


def tier3_checksums(ms_cur, pg_cur, matched):
    emit("\n## Tier 3 — Column Aggregate Checksums")
    fails = 0
    for tbl in sorted(matched):
        schema, table = tbl.split(".", 1)
        is_drift = tbl in KNOWN_DRIFT
        try:
            col_fails, col_warns = _col_checks(ms_cur, pg_cur, schema, table, tbl)
        except Exception as exc:
            record("FAIL", tbl, f"unexpected error: {exc}")
            fails += 1
            continue

        if col_fails:
            label = "WARN" if is_drift else "FAIL"
            suffix = "  (known API drift)" if is_drift else ""
            record(label, tbl,
                   f"{len(col_fails)} column checksum(s) differ{suffix}")
            for f in col_fails:
                emit(f"      • {f}")
            if not is_drift:
                fails += 1
        elif col_warns:
            record("WARN", tbl, f"{len(col_warns)} warning(s)")
            for w in col_warns:
                emit(f"      ⚠ {w}")
        else:
            record("PASS", tbl, "all columns pass")

    return fails


# ─────────────────────────────────────────────────────────────────────────────
# Tier 4 — Sample Row Spot-Check
# ─────────────────────────────────────────────────────────────────────────────

def _normalize_val(val, dtype):
    """Normalize a value so MSSQL and PG representations can be compared."""
    if val is None:
        return None
    if dtype in APPROX_TYPES:
        return round(float(val), 6)
    if dtype in NUMERIC_TYPES:
        return float(decimal.Decimal(str(val)))
    if dtype in STRING_TYPES:
        return str(val).rstrip()
    if dtype in DATE_TYPES:
        return str(val)[:19]
    if dtype in BIT_TYPES:
        return bool(val)
    if dtype == "uniqueidentifier":
        return str(val).lower()
    return val


def tier4_spot_check(ms_cur, pg_cur, matched):
    emit("\n## Tier 4 — Sample Row Spot-Check")
    fails = 0
    for tbl in sorted(matched):
        schema, table = tbl.split(".", 1)
        is_drift = tbl in KNOWN_DRIFT

        # Require a single-column PK for deterministic row lookup
        ms_cur.execute("""
            SELECT ku.COLUMN_NAME
            FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
            JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE ku
              ON tc.CONSTRAINT_NAME = ku.CONSTRAINT_NAME
             AND tc.TABLE_SCHEMA    = ku.TABLE_SCHEMA
            WHERE tc.TABLE_SCHEMA     = %s
              AND tc.TABLE_NAME       = %s
              AND tc.CONSTRAINT_TYPE  = 'PRIMARY KEY'
            ORDER BY ku.ORDINAL_POSITION
        """, (schema, table))
        pk_cols = [r[0] for r in ms_cur.fetchall()]

        if len(pk_cols) != 1:
            record("SKIP", tbl,
                   f"composite or missing PK ({len(pk_cols)} PK cols) — skipped")
            continue

        pk    = pk_cols[0]
        pk_pg = pk.lower()

        # Column list shared between MSSQL and PG (skip geography/binary)
        ms_cur.execute("""
            SELECT COLUMN_NAME, DATA_TYPE
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = %s AND TABLE_NAME = %s
            ORDER BY ORDINAL_POSITION
        """, (schema, table))
        ms_cols_raw = [(r[0], r[1].lower()) for r in ms_cur.fetchall()]

        pg_cur.execute("""
            SELECT column_name
            FROM information_schema.columns
            WHERE table_schema = %s AND table_name = %s
        """, (schema, table))
        pg_col_set = {r[0].lower() for r in pg_cur.fetchall()}

        shared_cols = [
            (c, t) for c, t in ms_cols_raw
            if c.lower() in pg_col_set and t not in SKIP_TYPES
        ]

        # Draw random sample PKs from MSSQL
        try:
            ms_cur.execute(
                f"SELECT TOP {SPOT_SAMPLE} [{pk}] "
                f"FROM [{schema}].[{table}] ORDER BY NEWID()")
            sample_pks = [r[0] for r in ms_cur.fetchall()]
        except Exception as exc:
            record("WARN", tbl, f"could not sample PKs: {exc}")
            continue

        if not sample_pks:
            record("SKIP", tbl, "table is empty")
            continue

        ms_sel = ", ".join(f"[{c}]" for c, _ in shared_cols)
        pg_sel = ", ".join(c.lower() for c, _ in shared_cols)

        row_fails = []
        row_warns = []
        for pk_val in sample_pks:
            try:
                ms_cur.execute(
                    f"SELECT {ms_sel} FROM [{schema}].[{table}] WHERE [{pk}] = %s",
                    (pk_val,))
                ms_row = ms_cur.fetchone()

                pg_cur.execute(
                    f"SELECT {pg_sel} FROM {tbl} WHERE {pk_pg} = %s",
                    (pk_val,))
                pg_row = pg_cur.fetchone()

                if pg_row is None:
                    row_fails.append(
                        f"PK={pk_val}: row present in MSSQL but missing in PG")
                    continue

                for i, (col_name, dtype) in enumerate(shared_cols):
                    ms_v = _normalize_val(ms_row[i], dtype)
                    pg_v = _normalize_val(pg_row[i], dtype)

                    if dtype in APPROX_TYPES:
                        ok = floats_close(ms_v, pg_v, REL_TOL_APPROX)
                    else:
                        ok = (ms_v == pg_v)

                    if not ok:
                        msg = (f"PK={pk_val}  col={col_name}: "
                               f"MSSQL={repr(ms_v)}  PG={repr(pg_v)}")
                        if is_drift:
                            row_warns.append(msg)
                        else:
                            row_fails.append(msg)

            except Exception as exc:
                row_fails.append(f"PK={pk_val}: error — {exc}")

        if row_fails:
            label = "FAIL" if not is_drift else "WARN"
            record(label, tbl,
                   f"{len(row_fails)} row-level failure(s) in "
                   f"{len(sample_pks)} sampled rows")
            for msg in row_fails[:5]:
                emit(f"      • {msg}")
            if len(row_fails) > 5:
                emit(f"      ... and {len(row_fails) - 5} more")
            if not is_drift:
                fails += 1
        elif row_warns:
            record("WARN", tbl,
                   f"{len(row_warns)} value(s) differ in "
                   f"{len(sample_pks)} sampled rows  (expected API drift)")
        else:
            record("PASS", tbl,
                   f"{len(sample_pks)} sampled rows  ×  {len(shared_cols)} columns  all match")

    return fails


# ─────────────────────────────────────────────────────────────────────────────
# Tier 5 — Referential Integrity (FK orphan check)
# FK definitions sourced from MSSQL sys catalog; orphan queries run against PG
# ─────────────────────────────────────────────────────────────────────────────

def tier5_fk_integrity(ms_cur, pg_cur):
    emit("\n## Tier 5 — Referential Integrity (FK Orphan Check)")

    schema_list = ", ".join(f"'{s}'" for s in MSSQL_SCHEMAS)
    ms_cur.execute(f"""
        SELECT
            LOWER(ps.name)  AS child_schema,
            LOWER(pt.name)  AS child_table,
            LOWER(c.name)   AS child_col,
            LOWER(rs.name)  AS parent_schema,
            LOWER(rt.name)  AS parent_table,
            LOWER(rc.name)  AS parent_col,
            fk.name         AS fk_name
        FROM sys.foreign_keys           fk
        JOIN sys.foreign_key_columns    fkc
          ON fk.object_id = fkc.constraint_object_id
        JOIN sys.columns c
          ON fkc.parent_object_id  = c.object_id
         AND fkc.parent_column_id  = c.column_id
        JOIN sys.columns rc
          ON fkc.referenced_object_id = rc.object_id
         AND fkc.referenced_column_id = rc.column_id
        JOIN sys.objects pt ON pt.object_id = fk.parent_object_id
        JOIN sys.schemas ps ON ps.schema_id = pt.schema_id
        JOIN sys.objects rt ON rt.object_id = fk.referenced_object_id
        JOIN sys.schemas rs ON rs.schema_id = rt.schema_id
        WHERE ps.name IN ({schema_list})
        ORDER BY child_schema, child_table, fk_name
    """)
    fk_rows = ms_cur.fetchall()
    emit(f"  Found {len(fk_rows)} FK column relationships in MSSQL")

    # Group by FK name to correctly handle composite FKs
    fk_map = defaultdict(list)
    for row in fk_rows:
        child_s, child_t, child_c, par_s, par_t, par_c, fk_name = row
        fk_map[fk_name].append({
            "child_schema": child_s, "child_table": child_t, "child_col": child_c,
            "parent_schema": par_s, "parent_table": par_t, "parent_col": par_c,
        })

    fails = 0
    for fk_name, cols in sorted(fk_map.items()):
        child  = f"{cols[0]['child_schema']}.{cols[0]['child_table']}"
        parent = f"{cols[0]['parent_schema']}.{cols[0]['parent_table']}"

        if len(cols) == 1:
            cc, pc = cols[0]["child_col"], cols[0]["parent_col"]
            join_on  = f"c.{cc} = p.{pc}"
            not_null = f"c.{cc} IS NOT NULL"
            null_chk = f"p.{pc} IS NULL"
        else:
            join_on  = " AND ".join(
                f"c.{x['child_col']} = p.{x['parent_col']}" for x in cols)
            not_null = " AND ".join(
                f"c.{x['child_col']} IS NOT NULL" for x in cols)
            # After LEFT JOIN, all parent PK cols are NULL iff no match was found
            null_chk = " AND ".join(
                f"p.{x['parent_col']} IS NULL" for x in cols)

        sql = (f"SELECT COUNT(*) FROM {child} c "
               f"LEFT JOIN {parent} p ON {join_on} "
               f"WHERE ({null_chk}) AND ({not_null})")
        try:
            orphans = scalar(pg_cur, sql)
            if orphans and orphans > 0:
                record("FAIL", f"{child} → {parent}",
                       f"{fmt(orphans)} orphaned rows  [{fk_name}]")
                fails += 1
            else:
                record("PASS", f"{child} → {parent}", "0 orphans")
        except Exception as exc:
            record("WARN", f"{child} → {parent}",
                   f"could not check [{fk_name}]: {exc}")

    if not fk_map:
        record("WARN", "FK check",
               "No FK relationships found in MSSQL — "
               "FK constraints may not be declared in PG schema")

    return fails


# ─────────────────────────────────────────────────────────────────────────────
# Tier 6 — Sequence Alignment
# ─────────────────────────────────────────────────────────────────────────────

def tier6_sequences(pg_cur):
    emit("\n## Tier 6 — Sequence Alignment")

    pg_cur.execute("""
        SELECT sequence_schema, sequence_name
        FROM information_schema.sequences
        WHERE sequence_schema = 'sequences'
        ORDER BY sequence_name
    """)
    seqs = pg_cur.fetchall()
    emit(f"  Found {len(seqs)} sequences in 'sequences' schema")

    fails = 0
    for seq_schema, seq_name in seqs:
        try:
            pg_cur.execute(f"SELECT last_value, is_called FROM {seq_schema}.{seq_name}")
            row      = pg_cur.fetchone()
            last_val = row[0] if row else None
        except Exception as exc:
            record("WARN", f"{seq_schema}.{seq_name}", f"could not read: {exc}")
            continue

        # Locate the consuming column via its DEFAULT expression
        pg_cur.execute("""
            SELECT table_schema, table_name, column_name
            FROM information_schema.columns
            WHERE column_default LIKE %s
              AND table_schema != 'sequences'
            LIMIT 1
        """, (f"%{seq_schema}.{seq_name}%",))
        info = pg_cur.fetchone()

        if not info:
            record("WARN", f"{seq_schema}.{seq_name}",
                   f"last_value={fmt(last_val)}  — no consuming column found")
            continue

        tbl_schema, tbl_name, col_name = info
        tbl = f"{tbl_schema}.{tbl_name}"

        try:
            max_pk = scalar(pg_cur, f"SELECT MAX({col_name}) FROM {tbl}")
            if max_pk is None:
                record("PASS", f"{seq_schema}.{seq_name}",
                       f"last_value={fmt(last_val)}  {tbl} is empty")
            elif last_val is None or last_val < max_pk:
                record("FAIL", f"{seq_schema}.{seq_name}",
                       f"last_value={fmt(last_val)} < MAX({col_name})={fmt(max_pk)} "
                       f"in {tbl}  — INSERT CONFLICT RISK")
                fails += 1
            else:
                record("PASS", f"{seq_schema}.{seq_name}",
                       f"last_value={fmt(last_val)} >= MAX({col_name})={fmt(max_pk)}")
        except Exception as exc:
            record("WARN", f"{seq_schema}.{seq_name}",
                   f"could not verify MAX PK: {exc}")

    return fails


# ─────────────────────────────────────────────────────────────────────────────
# Report writer
# ─────────────────────────────────────────────────────────────────────────────

def write_report(elapsed):
    today = datetime.date.today().isoformat()
    header = [
        f"# Migration Full Test Report — {today}",
        "",
        "## Overall Summary",
        f"- Elapsed: {elapsed:.1f}s",
        f"- **PASS: {_counts['PASS']}**  "
        f"FAIL: {_counts['FAIL']}  "
        f"WARN: {_counts['WARN']}  "
        f"SKIP: {_counts['SKIP']}",
        "",
    ]
    if _fail_lines:
        header += ["## Failures", ""]
        for f in _fail_lines:
            header.append(f"- {f}")
        header.append("")
    header += ["---", "## Detailed Results", ""]

    content = "\n".join(header + _report)
    path = os.path.realpath(
        os.getenv("REPORT_PATH",
                  os.path.join(os.path.dirname(__file__),
                               "..", "docs", "migration-test-report.md")))
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as fh:
        fh.write(content)
    return path


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

def main():
    emit(f"# Migration Full Test — {datetime.datetime.now():%Y-%m-%d %H:%M:%S}")
    emit(f"  MSSQL  {MSSQL_HOST}:{MSSQL_CFG['port']}  db={MSSQL_CFG['database']}")
    emit(f"  PG     {PG_HOST}:{PG_CFG['port']}  db={PG_CFG['dbname']}")

    print("\nConnecting...", flush=True)
    ms = pymssql.connect(**MSSQL_CFG)
    pg = psycopg2.connect(**PG_CFG)
    pg.autocommit = True
    ms_cur = ms.cursor()
    pg_cur = pg.cursor()
    print("  MSSQL OK   PG OK\n", flush=True)

    t0 = time.time()

    matched = tier1_inventory(ms_cur, pg_cur)
    tier2_row_counts(ms_cur, pg_cur, matched)
    tier3_checksums(ms_cur, pg_cur, matched)
    tier4_spot_check(ms_cur, pg_cur, matched)
    tier5_fk_integrity(ms_cur, pg_cur)
    tier6_sequences(pg_cur)

    elapsed = time.time() - t0

    emit(f"\n## Final Tally  ({elapsed:.1f}s elapsed)")
    emit(f"  PASS: {_counts['PASS']}  FAIL: {_counts['FAIL']}  "
         f"WARN: {_counts['WARN']}  SKIP: {_counts['SKIP']}")

    ms_cur.close()
    pg_cur.close()
    ms.close()
    pg.close()

    path = write_report(elapsed)
    emit(f"\nReport written: {path}")

    sys.exit(1 if _counts["FAIL"] > 0 else 0)


if __name__ == "__main__":
    main()
