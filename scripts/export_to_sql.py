"""
Export WideWorldImporters data from MSSQL to PostgreSQL-compatible .sql INSERT files.
Run this locally where wwi_mssql is running.

Usage:
    docker run --rm \
      --network wideworldimporters-mssql_wwi-net \
      --network appz-images_agentomatic_net \
      -v "$(pwd)/scripts:/scripts" \
      -v "$(pwd)/export:/export" \
      -e MSSQL_HOST=172.20.0.3 \
      python:3.12-slim \
      bash -c "pip install -q pymssql && python3 /scripts/export_to_sql.py"

Output: export/sql/ — one .sql file per table, ready to load on the server with:
    bash scripts/load-export.sh
"""
import os
import sys
import pymssql
from datetime import date, datetime
from decimal import Decimal

MSSQL = dict(
    server=os.getenv("MSSQL_HOST", "172.20.0.3"),
    port=int(os.getenv("MSSQL_PORT", 1433)),
    user=os.getenv("MSSQL_USER", "sa"),
    password=os.getenv("MSSQL_PASS", "Sp1d3rman!"),
    database=os.getenv("MSSQL_DB", "WideWorldImporters"),
)

OUTPUT_DIR = os.getenv("OUTPUT_DIR", "/export/sql")
BATCH = 5000

# All tables in FK dependency order
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

# Tables that need OVERRIDING SYSTEM VALUE (GENERATED ALWAYS identity columns)
OVERRIDE_TABLES = {"warehouse.vehicletemperatures", "warehouse.coldroomtemperatures"}


def get_mssql_columns(ms, src):
    schema, table = src.split(".")
    cur = ms.cursor()
    cur.execute("""
        SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA=%s AND TABLE_NAME=%s
        ORDER BY ORDINAL_POSITION
    """, (schema, table))
    return [r[0] for r in cur.fetchall()]


def escape_value(v):
    """Convert a Python value to a PostgreSQL literal."""
    if v is None:
        return "NULL"
    if isinstance(v, bool):
        return "TRUE" if v else "FALSE"
    if isinstance(v, (int, float, Decimal)):
        return str(v)
    if isinstance(v, (date, datetime)):
        return f"'{v}'"
    if isinstance(v, (bytes, bytearray)):
        # geography/binary — store as NULL (no PostGIS on target)
        return "NULL"
    # String — escape single quotes
    escaped = str(v).replace("'", "''")
    return f"'{escaped}'"


def export_table(ms, src, dst, out_dir):
    ms_cols = get_mssql_columns(ms, src)
    # Filter out geography columns by checking them dynamically
    col_list_sql = ", ".join(f"[{c}]" for c in ms_cols)
    override = "OVERRIDING SYSTEM VALUE " if dst in OVERRIDE_TABLES else ""

    cur = ms.cursor()
    cur.execute(f"SELECT {col_list_sql} FROM {src}")

    # Output file named by load order (index in TABLES list)
    idx = next(i for i, (s, d) in enumerate(TABLES) if d == dst)
    safe_name = dst.replace(".", "_")
    filepath = os.path.join(out_dir, f"{idx:02d}_{safe_name}.sql")

    pg_cols = ", ".join(f'"{c.lower()}"' for c in ms_cols)

    total = 0
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(f"-- {src} -> {dst}\n")
        f.write(f"SET session_replication_role = replica;\n")
        f.write(f"TRUNCATE {dst} CASCADE;\n\n")

        while True:
            rows = cur.fetchmany(BATCH)
            if not rows:
                break
            values_list = []
            for row in rows:
                values = ", ".join(escape_value(v) for v in row)
                values_list.append(f"  ({values})")

            f.write(f"INSERT INTO {dst} ({pg_cols}) {override}VALUES\n")
            f.write(",\n".join(values_list))
            f.write(";\n\n")
            total += len(rows)
            print(f"  {total} rows...", end="\r", flush=True)

    print(f"  {total} rows exported -> {os.path.basename(filepath)}")
    return total


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    print("Connecting to MSSQL...")
    ms = pymssql.connect(**MSSQL)

    grand_total = 0
    for src, dst in TABLES:
        print(f"\n-> {src} -> {dst}")
        try:
            n = export_table(ms, src, dst, OUTPUT_DIR)
            grand_total += n
        except Exception as e:
            print(f"  ERROR: {e}")

    ms.close()
    print(f"\nDone. {grand_total:,} total rows exported to {OUTPUT_DIR}/")
    print("Copy the export/ folder to the server and run: bash scripts/load-export.sh")


if __name__ == "__main__":
    main()
