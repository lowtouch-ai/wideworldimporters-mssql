# Conversion summary: DataLoadSimulation.PickStockForCustomerOrders

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/PickStockForCustomerOrders.sql`
- **Pattern:** Cursor + MERGE on table variable
- **Output:** `postgres/DataLoadSimulation/Functions/pick_stock_for_customer_orders.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.pick_stock_for_customer_orders(p_current_date_time timestamp, p_starting_when timestamp, p_end_of_time timestamp, p_is_silent_mode boolean) RETURNS void
```

## Conversion notes
- `@UninvoicedOrders TABLE` and `@StockAlreadyAllocated TABLE` → `CREATE TEMP TABLE ... ON COMMIT DROP`
- `DECLARE OrderLineList CURSOR FAST_FORWARD READ_ONLY FOR ... WHILE @@FETCH_STATUS` → `FOR rec IN (...) LOOP`
- `MERGE @StockAlreadyAllocated ... WHEN MATCHED THEN UPDATE ... WHEN NOT MATCHED THEN INSERT` → `INSERT INTO ... ON CONFLICT DO UPDATE SET ...`
- `QuantityAllocated += Quantity` → `quantity_allocated = stock_already_allocated.quantity_allocated + EXCLUDED.quantity_allocated`

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.orders` | `postgres/Sales/Tables/Orders.sql` |
| `sales.orderlines` | `postgres/Sales/Tables/OrderLines.sql` |
| `sales.invoices` | `postgres/Sales/Tables/Invoices.sql` |
| `warehouse.stockitemholdings` | `postgres/Warehouse/Tables/StockItemHoldings.sql` |
