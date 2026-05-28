# Conversion summary: Integration.GetSaleUpdates

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetSaleUpdates.sql`
- **Pattern:** Search / Query
- **Output:** `postgres/Integration/Functions/get_sale_updates.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION integration.get_sale_updates(
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
- `[Description]` square brackets stripped
- `CASE WHEN si.IsChillerStock = 0` → `CASE WHEN si.IsChillerStock = false` (bit → boolean)
- `CASE WHEN si.IsChillerStock <> 0` → `CASE WHEN si.IsChillerStock <> false`
- `[WWI Saleperson ID]` typo preserved as-is from original source
- Self-join `Sales.Customers AS bt` (BillToCustomer existence check) preserved — no columns referenced from it in SELECT
- `ConfirmedDeliveryTime` can be NULL → `Delivery Date Key` column is nullable
- Schema/table names lowercased throughout

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.invoices` | `postgres/Sales/Tables/Invoices.sql` |
| `sales.invoicelines` | `postgres/Sales/Tables/InvoiceLines.sql` |
| `warehouse.stockitems` | `postgres/Warehouse/Tables/StockItems.sql` |
| `warehouse.packagetypes` | `postgres/Warehouse/Tables/PackageTypes.sql` |
| `sales.customers` | `postgres/Sales/Tables/Customers.sql` |
