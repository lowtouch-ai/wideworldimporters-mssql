# Conversion summary: Integration.GetTransactionUpdates

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetTransactionUpdates.sql`
- **Pattern:** Search / Query
- **Output:** `postgres/Integration/Functions/get_transaction_updates.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION integration.get_transaction_updates(
    p_last_cutoff timestamp,
    p_new_cutoff  timestamp
) RETURNS TABLE(...)
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@LastCutoff datetime2(7)` | `p_last_cutoff timestamp` | timestamp | Lower bound (exclusive) |
| `@NewCutoff datetime2(7)` | `p_new_cutoff timestamp` | timestamp | Upper bound (inclusive) |

## Conversion notes
- `datetime2(7)` → `timestamp`
- `RETURN 0` removed (TABLE-returning function uses `RETURN QUERY`)
- `SET NOCOUNT ON` / `SET XACT_ABORT ON` / `WITH EXECUTE AS OWNER` removed
- `CAST(NULL AS int)` → `CAST(NULL AS integer)` (6 occurrences for placeholder columns)
- `CAST(NULL AS nvarchar(20))` → `CAST(NULL AS varchar(20))` (Supplier Invoice Number on customer side)
- `bit` columns `IsFinalized` → `boolean` on both branches
- `COALESCE(i.CustomerID, ct.CustomerID)` unchanged — standard SQL
- `UNION ALL` of CustomerTransactions + SupplierTransactions preserved
- `LEFT OUTER JOIN Sales.Invoices` → `LEFT OUTER JOIN sales.invoices`
- Schema/table names lowercased throughout

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.customertransactions` | `postgres/Sales/Tables/CustomerTransactions.sql` |
| `sales.invoices` | `postgres/Sales/Tables/Invoices.sql` |
| `purchasing.suppliertransactions` | `postgres/Purchasing/Tables/SupplierTransactions.sql` |
