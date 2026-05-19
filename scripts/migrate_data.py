"""
Migrate WideWorldImporters data from MSSQL to PostgreSQL.
Tables are migrated in FK dependency order.
"""
import pymssql
import psycopg2
import psycopg2.extras
import sys

MSSQL = dict(server="172.20.0.3", port=1433, user="sa", password="Sp1d3rman!", database="WideWorldImporters")
PG    = dict(host="172.19.0.5", port=5432, user="postgres", password="postgres", dbname="postgres")

# (mssql_schema.Table, pg_schema.table) — only the tables that failed (generated columns)
TABLES = [
    ("Application.People",             "application.people"),
    ("Application.SystemParameters",   "application.systemparameters"),
    ("Warehouse.StockItems",           "warehouse.stockitems"),
    ("Purchasing.SupplierTransactions","purchasing.suppliertransactions"),
    ("Sales.CustomerTransactions",     "sales.customertransactions"),
]

BATCH = 2000

def get_pg_columns(pg, pg_table):
    schema, table = pg_table.split(".")
    cur = pg.cursor()
    cur.execute("""
        SELECT column_name FROM information_schema.columns
        WHERE table_schema=%s AND table_name=%s
          AND is_generated = 'NEVER'
        ORDER BY ordinal_position
    """, (schema, table))
    return [r[0] for r in cur.fetchall()]

def migrate_table(ms, pg, src, dst):
    cols = get_pg_columns(pg, dst)
    col_list   = ", ".join(f'"{c}"' for c in cols)
    src_cols   = ", ".join(f'[{c}]' for c in cols)
    placeholders = ", ".join(["%s"] * len(cols))

    pg_cur = pg.cursor()
    pg_cur.execute(f"TRUNCATE {dst} CASCADE")
    pg.commit()

    ms_cur = ms.cursor()
    ms_cur.execute(f"SELECT {src_cols} FROM {src}")

    total = 0
    while True:
        rows = ms_cur.fetchmany(BATCH)
        if not rows:
            break
        # Convert rows: replace any bytearray geography values with None
        clean = []
        for row in rows:
            clean.append(tuple(None if isinstance(v, (bytes, bytearray)) else v for v in row))
        psycopg2.extras.execute_values(
            pg_cur, f"INSERT INTO {dst} ({col_list}) VALUES %s ON CONFLICT DO NOTHING",
            clean, page_size=BATCH
        )
        pg.commit()
        total += len(rows)
        print(f"  {total} rows...", end="\r", flush=True)

    print(f"  {total} rows loaded       ")
    return total

def main():
    print("Connecting to MSSQL...")
    ms = pymssql.connect(**MSSQL)
    print("Connecting to PostgreSQL...")
    pg = psycopg2.connect(**PG)

    # Disable FK checks for the session
    pg_cur = pg.cursor()
    pg_cur.execute("SET session_replication_role = replica")
    pg.commit()

    grand_total = 0
    for src, dst in TABLES:
        print(f"\n→ {src} → {dst}")
        try:
            n = migrate_table(ms, pg, src, dst)
            grand_total += n
        except Exception as e:
            print(f"  ERROR: {e}")
            pg.rollback()

    # Re-enable FK checks
    pg_cur = pg.cursor()
    pg_cur.execute("SET session_replication_role = DEFAULT")
    pg.commit()

    ms.close()
    pg.close()
    print(f"\nDone. {grand_total:,} total rows migrated.")

if __name__ == "__main__":
    main()
