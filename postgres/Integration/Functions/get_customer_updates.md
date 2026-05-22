# Conversion summary: Integration.GetCustomerUpdates

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetCustomerUpdates.sql`
- **Pattern:** Complex / cursor / temporal
- **Output:** `postgres/Integration/Functions/get_customer_updates.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION integration.get_customer_updates(
    p_last_cutoff timestamp,
    p_new_cutoff  timestamp
) RETURNS TABLE(
    "WWI Customer ID" integer, "Customer" varchar(100), "Bill To Customer" varchar(100),
    "Category" varchar(50), "Buying Group" varchar(50), "Primary Contact" varchar(50),
    "Postal Code" varchar(10), "Valid From" timestamp, "Valid To" timestamp
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
- `cc.ValidFrom <> @InitialLoadDate` (datetime2 vs date implicit comparison in MSSQL) → `cc.ValidFrom::date <> _initial_load_date`
- 3 cursors converted to sequential FOR loops reusing `rec` (valid in PL/pgSQL since loops are sequential)
- `CREATE TABLE #CustomerChanges` → `DROP TABLE IF EXISTS customerchanges; CREATE TEMP TABLE customerchanges (...)`
- Cursor 1 (BuyingGroupChangeList): excludes initial load date; all-customer snapshot uses `DISTINCT ON (CustomerID)` with 5-table temporal JOIN; filtered by `c.BuyingGroupID = rec.buyinggroupid`
- Cursor 2 (CustomerCategoryChangeList): excludes initial load date; same 5-table JOIN; filtered by `cc.CustomerCategoryID = rec.customercategoryid`
- Cursor 3 (CustomerChangeList): includes initial load; `c` subquery uses `LIMIT 1 ORDER BY ValidFrom DESC` filtered by `CustomerID = rec.customerid`; other 4 tables still use `DISTINCT ON` snapshots
- `CREATE INDEX IX_CustomerChanges` → `CREATE INDEX ix_customerchanges`
- `UPDATE cc SET … FROM #CustomerChanges AS cc` → `UPDATE customerchanges AS cc SET …`
- Final SELECT → `RETURN QUERY SELECT … FROM customerchanges`

## TODOs
- **FOR SYSTEM_TIME AS OF rec.validfrom (5 temporal tables: Customers, CustomerCategories, Customers self-join for BillTo, People, BuyingGroups)** — Not natively supported in PostgreSQL. Approximation uses `DISTINCT ON (PK) ORDER BY PK, ValidFrom DESC` over `(archive_range UNION ALL current_table)` for each table. Cursor 3 Customers subquery uses `LIMIT 1` filtered by `CustomerID`. Verify deduplication correctness for edge cases where both archive and current rows match a given timestamp.

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.buyinggroups_archive` | `postgres/Sales/Tables/BuyingGroups_Archive.sql` |
| `sales.buyinggroups` | `postgres/Sales/Tables/BuyingGroups.sql` |
| `sales.customercategories_archive` | `postgres/Sales/Tables/CustomerCategories_Archive.sql` |
| `sales.customercategories` | `postgres/Sales/Tables/CustomerCategories.sql` |
| `sales.customers_archive` | `postgres/Sales/Tables/Customers_Archive.sql` |
| `sales.customers` | `postgres/Sales/Tables/Customers.sql` |
| `application.people_archive` | `postgres/Application/Tables/People_Archive.sql` |
| `application.people` | `postgres/Application/Tables/People.sql` |
