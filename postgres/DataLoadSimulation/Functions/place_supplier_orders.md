# Conversion summary: DataLoadSimulation.PlaceSupplierOrders

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/PlaceSupplierOrders.sql`
- **Pattern:** Complex DML (CTEs + table variables + INSERT)
- **Output:** `postgres/DataLoadSimulation/Functions/place_supplier_orders.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.place_supplier_orders(p_current_date_time timestamp, p_starting_when timestamp, p_end_of_time timestamp, p_is_silent_mode boolean) RETURNS void
```

## Conversion notes
- `@Orders TABLE` and `@OrderLines TABLE` → `CREATE TEMP TABLE ... ON COMMIT DROP`
- `NEXT VALUE FOR Sequences.PurchaseOrderID` → `nextval('sequences.purchase_order_id_seq')` called in SELECT
- `DATEADD(day, (SELECT MAX(LeadTimeDays) FROM @OrderLines), CAST(...))` → `CAST(p_starting_when AS date) + (SELECT MAX(lead_time_days) FROM order_lines_to_place)`
- `CEILING(...)` → `ceil(...)::integer`
- `IsOrderLineFinalized = 0` → `= false`

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `warehouse.stockitems` | `postgres/Warehouse/Tables/StockItems.sql` |
| `warehouse.stockitemholdings` | `postgres/Warehouse/Tables/StockItemHoldings.sql` |
| `sales.orderlines` | `postgres/Sales/Tables/OrderLines.sql` |
| `purchasing.purchaseorderlines` | `postgres/Purchasing/Tables/PurchaseOrderLines.sql` |
| `purchasing.purchaseorders` | `postgres/Purchasing/Tables/PurchaseOrders.sql` |
| `purchasing.suppliers` | `postgres/Purchasing/Tables/Suppliers.sql` |
