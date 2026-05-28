# Conversion summary: Integration.GetSupplierUpdates

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetSupplierUpdates.sql`
- **Pattern:** Complex / cursor / temporal
- **Output:** `postgres/Integration/Functions/get_supplier_updates.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION integration.get_supplier_updates(
    p_last_cutoff timestamp,
    p_new_cutoff  timestamp
) RETURNS TABLE(
    "WWI Supplier ID" integer, "Supplier" varchar(100), "Category" varchar(50),
    "Primary Contact" varchar(50), "Supplier Reference" varchar(20),
    "Payment Days" integer, "Postal Code" varchar(10),
    "Valid From" timestamp, "Valid To" timestamp
)
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@LastCutoff datetime2(7)` | `p_last_cutoff timestamp` | timestamp | Lower bound (exclusive) |
| `@NewCutoff datetime2(7)` | `p_new_cutoff timestamp` | timestamp | Upper bound (inclusive) |

## Conversion notes
- `DECLARE @EndOfTime datetime2(7) = '9999...'` → `_end_of_time timestamp := '9999-12-31 23:59:59.9999999'`
- `DECLARE @InitialLoadDate date = '20200101'` → `_initial_load_date date := '2020-01-01'`
- `cc.ValidFrom <> @InitialLoadDate` (datetime2 vs date comparison) → `cc.ValidFrom::date <> _initial_load_date`
- 2 cursors converted to sequential FOR loops reusing `rec` (valid in PL/pgSQL since loops are sequential)
- `CREATE TABLE #SupplierChanges` → `DROP TABLE IF EXISTS supplierchanges; CREATE TEMP TABLE supplierchanges (...)`
- Cursor 1 (SupplierCategoryChangeList): filters by `rec.suppliercategoryid`; Suppliers subquery uses `DISTINCT ON (SupplierID)` for all suppliers; SupplierCategories and People use `DISTINCT ON` snapshots
- Cursor 2 (SupplierChangeList): filters by `rec.supplierid`; Suppliers subquery uses `LIMIT 1 ORDER BY ValidFrom DESC`; SupplierCategories and People still use `DISTINCT ON` snapshots
- `CREATE INDEX IX_SupplierChanges` → `CREATE INDEX ix_supplierchanges`
- `UPDATE cc SET … FROM #SupplierChanges AS cc` → `UPDATE supplierchanges AS cc SET …`
- Final SELECT → `RETURN QUERY SELECT … FROM supplierchanges`

## TODOs
- **FOR SYSTEM_TIME AS OF rec.validfrom (3 temporal tables: Suppliers, SupplierCategories, People)** — Not natively supported in PostgreSQL. Approximation uses `DISTINCT ON (PK) ORDER BY PK, ValidFrom DESC` over `(archive_range UNION ALL current_table)` for each table. Verify deduplication correctness for edge cases where both archive and current rows match a given timestamp.

## Tables referenced
| Table | Postgres file |
|---|---|
| `purchasing.suppliercategories_archive` | `postgres/Purchasing/Tables/SupplierCategories_Archive.sql` |
| `purchasing.suppliercategories` | `postgres/Purchasing/Tables/SupplierCategories.sql` |
| `purchasing.suppliers_archive` | `postgres/Purchasing/Tables/Suppliers_Archive.sql` |
| `purchasing.suppliers` | `postgres/Purchasing/Tables/Suppliers.sql` |
| `application.people_archive` | `postgres/Application/Tables/People_Archive.sql` |
| `application.people` | `postgres/Application/Tables/People.sql` |
