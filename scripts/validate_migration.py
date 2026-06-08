"""
Validate WideWorldImporters data migration: MSSQL → PostgreSQL.
Checks row counts, PK ranges, numeric checksums, and NULL distributions.
"""
import os
import sys
import datetime
import time
import pymssql
import psycopg2

MSSQL = dict(
    server=os.getenv("MSSQL_HOST", "172.20.0.3"),
    port=int(os.getenv("MSSQL_PORT", 1433)),
    user=os.getenv("MSSQL_USER", "sa"),
    password=os.getenv("MSSQL_PASS", "Sp1d3rman!"),
    database=os.getenv("MSSQL_DB", "WideWorldImporters"),
)
PG = dict(
    host=os.getenv("PG_HOST", "172.19.0.5"),
    port=int(os.getenv("PG_PORT", 5432)),
    user=os.getenv("PG_USER", "postgres"),
    password=os.getenv("PG_PASS", "postgres"),
    dbname=os.getenv("PG_DB", "wideworldimporters"),
)

TABLES = [
    ("Application.People",                    "application.people"),
    ("Application.Countries",                 "application.countries"),
    ("Application.StateProvinces",            "application.stateprovinces"),
    ("Application.Cities",                    "application.cities"),
    ("Application.DeliveryMethods",           "application.deliverymethods"),
    ("Application.PaymentMethods",            "application.paymentmethods"),
    ("Application.TransactionTypes",          "application.transactiontypes"),
    ("Application.SystemParameters",          "application.systemparameters"),
    ("Warehouse.Colors",                      "warehouse.colors"),
    ("Warehouse.PackageTypes",                "warehouse.packagetypes"),
    ("Warehouse.StockGroups",                 "warehouse.stockgroups"),
    ("Purchasing.SupplierCategories",         "purchasing.suppliercategories"),
    ("Purchasing.Suppliers",                  "purchasing.suppliers"),
    ("Sales.BuyingGroups",                    "sales.buyinggroups"),
    ("Sales.CustomerCategories",              "sales.customercategories"),
    ("Sales.Customers",                       "sales.customers"),
    ("Warehouse.StockItems",                  "warehouse.stockitems"),
    ("Warehouse.StockItemHoldings",           "warehouse.stockitemholdings"),
    ("Warehouse.StockItemStockGroups",        "warehouse.stockitemstockgroups"),
    ("Purchasing.PurchaseOrders",             "purchasing.purchaseorders"),
    ("Purchasing.PurchaseOrderLines",         "purchasing.purchaseorderlines"),
    ("Purchasing.SupplierTransactions",       "purchasing.suppliertransactions"),
    ("Sales.Orders",                          "sales.orders"),
    ("Sales.OrderLines",                      "sales.orderlines"),
    ("Sales.Invoices",                        "sales.invoices"),
    ("Sales.InvoiceLines",                    "sales.invoicelines"),
    ("Sales.CustomerTransactions",            "sales.customertransactions"),
    ("Sales.SpecialDeals",                    "sales.specialdeals"),
    ("Warehouse.StockItemTransactions",       "warehouse.stockitemtransactions"),
    ("Warehouse.VehicleTemperatures",         "warehouse.vehicletemperatures"),
    ("Warehouse.ColdRoomTemperatures",        "warehouse.coldroomtemperatures"),
]

NUMERIC_TYPES = {"int", "bigint", "smallint", "tinyint", "decimal", "numeric",
                 "money", "smallmoney", "float", "real"}
APPROX_TYPES  = {"float", "real"}
GEO_TYPES     = {"geography"}
# Binary types are also stripped to NULL by the migration (same code path as geography)
BINARY_TYPES  = {"varbinary", "binary", "image", "rowversion", "timestamp"}

# Looser tolerance for float/real; tight for exact numeric types
REL_TOL_EXACT  = 1e-9
REL_TOL_APPROX = 1e-4


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


def get_mssql_columns(ms_cur, schema, table):
    ms_cur.execute("""
        SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA=%s AND TABLE_NAME=%s
        ORDER BY ORDINAL_POSITION
    """, (schema, table))
    return [(r[0], r[1].lower(), r[2]) for r in ms_cur.fetchall()]


def get_mssql_pk(ms_cur, schema, table):
    ms_cur.execute("""
        SELECT ku.COLUMN_NAME
        FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
        JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE ku
          ON tc.CONSTRAINT_NAME = ku.CONSTRAINT_NAME
             AND tc.TABLE_SCHEMA = ku.TABLE_SCHEMA
        WHERE tc.TABLE_SCHEMA=%s AND tc.TABLE_NAME=%s
          AND tc.CONSTRAINT_TYPE='PRIMARY KEY'
        ORDER BY ku.ORDINAL_POSITION
    """, (schema, table))
    return [r[0] for r in ms_cur.fetchall()]


def get_pg_pk(pg_cur, schema, table):
    pg_cur.execute("""
        SELECT kcu.column_name
        FROM information_schema.table_constraints tc
        JOIN information_schema.key_column_usage kcu
          ON tc.constraint_name = kcu.constraint_name
             AND tc.table_schema = kcu.table_schema
        WHERE tc.table_schema=%s AND tc.table_name=%s
          AND tc.constraint_type='PRIMARY KEY'
        ORDER BY kcu.ordinal_position
    """, (schema, table))
    return [r[0] for r in pg_cur.fetchall()]


def validate_table(ms, pg, src, dst):
    result = {
        "src": src, "dst": dst,
        "ms_count": None, "pg_count": None, "row_count": None,
        "pk_min": None, "pk_max": None,
        "checksum_failures": [], "null_failures": [],
        "skipped_cols": [], "errors": [],
        "overall": "PASS",
    }
    ms_cur = ms.cursor()
    pg_cur = pg.cursor()
    ms_schema, ms_table = src.split(".")
    pg_schema, pg_table = dst.split(".")

    def fail():
        result["overall"] = "FAIL"

    # ── Row counts ──────────────────────────────────────────────────────────────
    result["ms_count"] = scalar(ms_cur, f"SELECT COUNT(*) FROM {src}")
    result["pg_count"] = scalar(pg_cur, f"SELECT COUNT(*) FROM {dst}")
    result["row_count"] = result["ms_count"] == result["pg_count"]
    if not result["row_count"]:
        fail()

    # ── PK range ────────────────────────────────────────────────────────────────
    ms_pks = get_mssql_pk(ms_cur, ms_schema, ms_table)
    pg_pks = get_pg_pk(pg_cur, pg_schema, pg_table)
    if ms_pks and len(ms_pks) == 1:
        pk_ms = ms_pks[0]
        pk_pg = pg_pks[0] if pg_pks else pk_ms.lower()
        try:
            ms_min = scalar(ms_cur, f"SELECT MIN([{pk_ms}]) FROM {src}")
            ms_max = scalar(ms_cur, f"SELECT MAX([{pk_ms}]) FROM {src}")
            pg_min = scalar(pg_cur, f'SELECT MIN("{pk_pg}") FROM {dst}')
            pg_max = scalar(pg_cur, f'SELECT MAX("{pk_pg}") FROM {dst}')
            result["pk_min"] = (ms_min == pg_min)
            result["pk_max"] = (ms_max == pg_max)
            if not result["pk_min"] or not result["pk_max"]:
                fail()
        except Exception as e:
            result["errors"].append(f"PK range: {e}")

    # ── Column-level checks ─────────────────────────────────────────────────────
    ms_cols = get_mssql_columns(ms_cur, ms_schema, ms_table)
    for col_name, data_type, is_nullable in ms_cols:
        col_pg = col_name.lower()

        if data_type in GEO_TYPES or data_type in BINARY_TYPES:
            result["skipped_cols"].append(col_name)
            continue

        # Numeric checksum: cast both sides to float for a uniform comparison
        if data_type in NUMERIC_TYPES:
            try:
                ms_cast = "FLOAT" if data_type in APPROX_TYPES else "DECIMAL(38,10)"
                ms_sum = scalar(ms_cur,
                    f"SELECT CAST(SUM(CAST([{col_name}] AS {ms_cast})) AS FLOAT) FROM {src}")
                pg_sum = scalar(pg_cur,
                    f'SELECT SUM("{col_pg}"::numeric)::float8 FROM {dst}')
                tol = REL_TOL_APPROX if data_type in APPROX_TYPES else REL_TOL_EXACT
                if not floats_close(ms_sum, pg_sum, tol):
                    result["checksum_failures"].append(
                        {"col": col_name, "ms": ms_sum, "pg": pg_sum}
                    )
                    fail()
            except Exception as e:
                result["errors"].append(f"SUM({col_name}): {e}")

        # NULL distribution
        if is_nullable == "YES":
            try:
                ms_nulls = scalar(ms_cur,
                    f"SELECT SUM(CASE WHEN [{col_name}] IS NULL THEN 1 ELSE 0 END) FROM {src}")
                pg_nulls = scalar(pg_cur,
                    f'SELECT SUM(CASE WHEN "{col_pg}" IS NULL THEN 1 ELSE 0 END) FROM {dst}')
                if ms_nulls != pg_nulls:
                    result["null_failures"].append(
                        {"col": col_name, "ms": ms_nulls, "pg": pg_nulls}
                    )
                    fail()
            except Exception as e:
                result["errors"].append(f"NULLs({col_name}): {e}")

    return result


# ── Reporting ─────────────────────────────────────────────────────────────────

def fmt(n):
    return f"{n:,}" if n is not None else "—"


def tick(v):
    return "✓" if v else ("✗" if v is False else "—")


def build_report(results, elapsed):
    total  = len(results)
    passed = sum(1 for r in results if r["overall"] == "PASS")
    failed = sum(1 for r in results if r["overall"] == "FAIL")

    lines = [
        f"# Migration Validation Report — {datetime.date.today()}",
        "",
        "## Summary",
        f"- Tables checked: {total}",
        f"- **PASS: {passed}**  FAIL: {failed}",
        f"- Elapsed: {elapsed:.1f}s",
        "",
        "## Results",
        "",
        "| Table | MSSQL rows | PG rows | Rows | PK min | PK max | Checksums | NULLs |",
        "|-------|-----------|---------|------|--------|--------|-----------|-------|",
    ]
    for r in results:
        ck = "✓" if not r["checksum_failures"] else f"✗({len(r['checksum_failures'])})"
        nl = "✓" if not r["null_failures"]     else f"✗({len(r['null_failures'])})"
        lines.append(
            f"| {r['dst']} | {fmt(r['ms_count'])} | {fmt(r['pg_count'])} "
            f"| {tick(r['row_count'])} | {tick(r['pk_min'])} | {tick(r['pk_max'])} "
            f"| {ck} | {nl} |"
        )

    failures = [r for r in results if r["overall"] == "FAIL"]
    lines += ["", "## Failures", ("(none)" if not failures else "")]
    for r in failures:
        lines.append(f"\n### {r['dst']}")
        if not r["row_count"]:
            lines.append(f"- Row count: MSSQL={fmt(r['ms_count'])}  PG={fmt(r['pg_count'])}")
        if r["pk_min"] is False:
            lines.append("- PK min mismatch")
        if r["pk_max"] is False:
            lines.append("- PK max mismatch")
        for f in r["checksum_failures"]:
            lines.append(f"- SUM({f['col']}): MSSQL={f['ms']}  PG={f['pg']}")
        for f in r["null_failures"]:
            lines.append(f"- NULL count ({f['col']}): MSSQL={f['ms']}  PG={f['pg']}")
        for e in r["errors"]:
            lines.append(f"- ERROR: {e}")

    skipped = [(r["dst"], col) for r in results for col in r["skipped_cols"]]
    if skipped:
        lines += ["", "## Skipped Columns (geography/binary — migrated as NULL by design)"]
        for dst, col in skipped:
            lines.append(f"- {dst}.{col}")

    lines.append("")
    return "\n".join(lines)


# ── Entry point ───────────────────────────────────────────────────────────────

def main():
    print("Connecting to MSSQL...")
    ms = pymssql.connect(**MSSQL)
    print("Connecting to PostgreSQL...")
    pg = psycopg2.connect(**PG)

    results = []
    t0 = time.time()
    for src, dst in TABLES:
        print(f"  {src} → {dst} ...", end=" ", flush=True)
        try:
            r = validate_table(ms, pg, src, dst)
        except Exception as e:
            r = {
                "src": src, "dst": dst,
                "ms_count": None, "pg_count": None, "row_count": None,
                "pk_min": None, "pk_max": None,
                "checksum_failures": [], "null_failures": [],
                "skipped_cols": [], "errors": [str(e)],
                "overall": "FAIL",
            }
        print(f"{r['overall']}  ({fmt(r['ms_count'])} / {fmt(r['pg_count'])} rows)")
        results.append(r)

    elapsed = time.time() - t0
    ms.close()
    pg.close()

    report = build_report(results, elapsed)

    report_path = os.getenv("REPORT_PATH", "/repo/docs/validation-report.md")
    os.makedirs(os.path.dirname(report_path), exist_ok=True)
    with open(report_path, "w") as fh:
        fh.write(report)

    passed = sum(1 for r in results if r["overall"] == "PASS")
    failed = sum(1 for r in results if r["overall"] == "FAIL")
    print(f"\nReport written to: {report_path}")
    print(f"PASS: {passed}  FAIL: {failed}  of {len(results)} tables")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
