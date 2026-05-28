# Conversion summary: DataLoadSimulation.CreateCustomerOrders

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/CreateCustomerOrders.sql`
- **Pattern:** Complex DML (nested WHILE loops, ORDER/OrderLine INSERTs)
- **Output:** `postgres/DataLoadSimulation/Functions/create_customer_orders.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.create_customer_orders(p_current_date_time timestamp, p_starting_when timestamp, p_end_of_time timestamp, p_number_of_customer_orders integer, p_is_silent_mode boolean) RETURNS void
```

## Conversion notes
- `SET DATEFIRST 7; DATEPART(weekday, ...) IN (1, 7)` (Sun=1, Sat=7) → `EXTRACT(DOW FROM ...) IN (0, 6)` (Sun=0, Sat=6)
- `DATEADD(day, 1, @CurrentDateTime)` → `CAST(p_current_date_time AS date) + 1`
- `NEXT VALUE FOR Sequences.OrderID` → `nextval('sequences.order_id_seq')`
- `Website.CalculateCustomerPrice(...)` → `website.calculate_customer_price(...)`
- `CEILING(RAND() * 10000) + 10000` → `ceil(random() * 10000)::integer + 10000`
- `SELECT TOP(1) ... ORDER BY NEWID()` → `SELECT ... ORDER BY random() LIMIT 1`

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.orders` | `postgres/Sales/Tables/Orders.sql` |
| `sales.orderlines` | `postgres/Sales/Tables/OrderLines.sql` |
| `warehouse.stockitems` | `postgres/Warehouse/Tables/StockItems.sql` |
