"""
Migrate WideWorldImporters data from MSSQL to PostgreSQL.
Tables are migrated in FK dependency order.
"""
import os
import pymssql
import psycopg2
import psycopg2.extras
import sys
MSSQL = dict(server=os.getenv("MSSQL_HOST", "172.20.0.3"), port=int(os.getenv("MSSQL_PORT", 1433)),
             user=os.getenv("MSSQL_USER", "sa"), password=os.getenv("MSSQL_PASS", "Sp1d3rman!"),
             database=os.getenv("MSSQL_DB", "WideWorldImporters"))
PG    = dict(host=os.getenv("PG_HOST", "172.19.0.5"), port=int(os.getenv("PG_PORT", 5432)),
             user=os.getenv("PG_USER", "postgres"), password=os.getenv("PG_PASS", "postgres"),
             dbname=os.getenv("PG_DB", "wideworldimporters"))

# All tables in FK dependency order (leaves first, dependents last)
TABLES = [
    # Application reference
    ("Application.People",                    "application.people"),
    ("Application.Countries",                 "application.countries"),
    ("Application.StateProvinces",            "application.stateprovinces"),
    ("Application.Cities",                    "application.cities"),
    ("Application.DeliveryMethods",           "application.deliverymethods"),
    ("Application.PaymentMethods",            "application.paymentmethods"),
    ("Application.TransactionTypes",          "application.transactiontypes"),
    ("Application.SystemParameters",          "application.systemparameters"),
    # Warehouse reference
    ("Warehouse.Colors",                      "warehouse.colors"),
    ("Warehouse.PackageTypes",                "warehouse.packagetypes"),
    ("Warehouse.StockGroups",                 "warehouse.stockgroups"),
    # Purchasing reference
    ("Purchasing.SupplierCategories",         "purchasing.suppliercategories"),
    ("Purchasing.Suppliers",                  "purchasing.suppliers"),
    # Sales reference
    ("Sales.BuyingGroups",                    "sales.buyinggroups"),
    ("Sales.CustomerCategories",              "sales.customercategories"),
    ("Sales.Customers",                       "sales.customers"),
    # Warehouse transactional
    ("Warehouse.StockItems",                  "warehouse.stockitems"),
    ("Warehouse.StockItemHoldings",           "warehouse.stockitemholdings"),
    ("Warehouse.StockItemStockGroups",        "warehouse.stockitemstockgroups"),
    # Purchasing transactional
    ("Purchasing.PurchaseOrders",             "purchasing.purchaseorders"),
    ("Purchasing.PurchaseOrderLines",         "purchasing.purchaseorderlines"),
    ("Purchasing.SupplierTransactions",       "purchasing.suppliertransactions"),
    # Sales transactional
    ("Sales.Orders",                          "sales.orders"),
    ("Sales.OrderLines",                      "sales.orderlines"),
    ("Sales.Invoices",                        "sales.invoices"),
    ("Sales.InvoiceLines",                    "sales.invoicelines"),
    ("Sales.CustomerTransactions",            "sales.customertransactions"),
    ("Sales.SpecialDeals",                    "sales.specialdeals"),
    # Warehouse sensor/transactions
    ("Warehouse.StockItemTransactions",       "warehouse.stockitemtransactions"),
    ("Warehouse.VehicleTemperatures",         "warehouse.vehicletemperatures"),
    ("Warehouse.ColdRoomTemperatures",        "warehouse.coldroomtemperatures"),
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

def get_mssql_columns(ms, src):
    schema, table = src.split(".")
    cur = ms.cursor()
    cur.execute("""
        SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA=%s AND TABLE_NAME=%s
        ORDER BY ORDINAL_POSITION
    """, (schema, table))
    return [r[0] for r in cur.fetchall()]

def migrate_table(ms, pg, src, dst):
    pg_cols   = get_pg_columns(pg, dst)
    ms_cols   = get_mssql_columns(ms, src)
    # Match PG columns to MSSQL columns case-insensitively
    ms_map    = {c.lower(): c for c in ms_cols}
    matched   = [ms_map[c.lower()] for c in pg_cols if c.lower() in ms_map]
    pg_matched = [c for c in pg_cols if c.lower() in ms_map]

    col_list  = ", ".join(f'"{c}"' for c in pg_matched)
    src_cols  = ", ".join(f'[{c}]' for c in matched)
    placeholders = ", ".join(["%s"] * len(pg_matched))

    pg_cur = pg.cursor()
    pg_cur.execute(f"TRUNCATE {dst} CASCADE")
    pg.commit()

    ms_cur = ms.cursor()
    ms_cur.execute(f"SELECT {src_cols} FROM {src}")
    print(f"  Columns: {len(pg_matched)} matched")

    total = 0
    while True:
        rows = ms_cur.fetchmany(BATCH)
        if not rows:
            break
        # Convert rows: replace any bytearray geography values with None
        clean = []
        for row in rows:
            clean.append(tuple(None if isinstance(v, (bytes, bytearray)) else v for v in row))
        override = "OVERRIDING SYSTEM VALUE " if dst in (
            "warehouse.vehicletemperatures", "warehouse.coldroomtemperatures"
        ) else ""
        psycopg2.extras.execute_values(
            pg_cur, f"INSERT INTO {dst} ({col_list}) {override}VALUES %s ON CONFLICT DO NOTHING",
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
