# Conversion summary: Website.InsertCustomerOrders

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Website/Stored Procedures/InsertCustomerOrders.sql`
- **Pattern:** TVP-based transaction → `RETURNS void`
- **Output:** `postgres/Website/Functions/insert_customer_orders.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION website.insert_customer_orders(
    p_orders website.order_list[],
    p_order_lines website.order_line_list[],
    p_orders_created_by_person_id integer,
    p_salesperson_person_id integer
) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@Orders Website.OrderList READONLY` | `p_orders website.order_list[]` | composite type array | TVP → array of composite type |
| `@OrderLines Website.OrderLineList READONLY` | `p_order_lines website.order_line_list[]` | composite type array | TVP → array of composite type |
| `@OrdersCreatedByPersonID int` | `p_orders_created_by_person_id integer` | integer | |
| `@SalespersonPersonID int` | `p_salesperson_person_id integer` | integer | |

## Conversion notes
- TVP `@Orders Website.OrderList READONLY` → `website.order_list[]` array; iterated via `UNNEST(p_orders) AS o`
- TVP `@OrderLines Website.OrderLineList READONLY` → `website.order_line_list[]` array; iterated via `UNNEST(p_order_lines) AS ol`
- `@OrdersToGenerate` table variable → `_orders_to_generate` TEMP TABLE (dropped before/after use for idempotency)
- `NEXT VALUE FOR Sequences.OrderID` → `nextval('sequences.order_id_seq')` (one call per order row in UNNEST)
- `Website.CalculateCustomerPrice(o.CustomerID, ol.StockItemID, SYSDATETIME())` → `website.calculate_customer_price(o.customerid, ol.stockitemid, CURRENT_DATE)` (date parameter)
- `SYSDATETIME()` → `CURRENT_TIMESTAMP` (for timestamps) / `CURRENT_DATE` (for date columns)
- `BEGIN TRAN`/`COMMIT` removed — functions participate in caller's transaction automatically
- `BEGIN TRY ... BEGIN CATCH` → `EXCEPTION WHEN OTHERS THEN` block

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.orders` | `postgres/Sales/Tables/Orders.sql` |
| `sales.orderlines` | `postgres/Sales/Tables/OrderLines.sql` |
| `warehouse.stockitems` | `postgres/Warehouse/Tables/StockItems.sql` |
