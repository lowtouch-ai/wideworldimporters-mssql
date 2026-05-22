# Conversion summary: DataLoadSimulation.AddStockItems

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/AddStockItems.sql`
- **Pattern:** Simple DML (date-conditional INSERTs)
- **Output:** `postgres/DataLoadSimulation/Functions/add_stock_items.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.add_stock_items(p_current_date_time timestamp, p_starting_when timestamp, p_end_of_time timestamp, p_is_silent_mode boolean) RETURNS void
```

## Conversion notes
- `CAST(@CurrentDateTime AS date) = '20220101'` → `CAST(p_current_date_time AS date) = '2022-01-01'`
- `IsChillerStock` bit literal `1` → `true`, `0` → `false`
- Inline subqueries for SupplierID, ColorID, PackageTypeID lookups preserved

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `warehouse.stockitems` | `postgres/Warehouse/Tables/StockItems.sql` |
| `warehouse.stockitemholdings` | `postgres/Warehouse/Tables/StockItemHoldings.sql` |
| `warehouse.stockitemstockgroups` | `postgres/Warehouse/Tables/StockItemStockGroups.sql` |
| `purchasing.suppliers` | `postgres/Purchasing/Tables/Suppliers.sql` |
| `warehouse.colors` | `postgres/Warehouse/Tables/Colors.sql` |
| `warehouse.packagetypes` | `postgres/Warehouse/Tables/PackageTypes.sql` |
| `warehouse.stockgroups` | `postgres/Warehouse/Tables/StockGroups.sql` |
