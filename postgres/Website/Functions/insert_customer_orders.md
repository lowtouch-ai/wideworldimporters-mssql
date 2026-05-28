# insert_customer_orders

Converted from: `wwi-ssdt/wwi-ssdt/Website/Stored Procedures/InsertCustomerOrders.sql`

## Summary

Inserts new customer orders and order lines, allocating new OrderIDs from a sequence and pricing each line via `website.calculate_customer_price`.

## Conversion notes

- `WITH EXECUTE AS OWNER`, `SET NOCOUNT ON`, `SET XACT_ABORT ON` removed
- `@Orders Website.OrderList READONLY` and `@OrderLines Website.OrderLineList READONLY` — MSSQL TVP parameters have no direct PostgreSQL equivalent. Replaced with `jsonb` parameters; callers must pass JSON arrays with the same field names.
- `NEXT VALUE FOR Sequences.OrderID` → `nextval('sequences.order_id_seq')`
- `SYSDATETIME()` → `CURRENT_TIMESTAMP`
- `DECLARE @var AS TABLE (...)` → `CREATE TEMP TABLE ... ON COMMIT DROP`
- `BEGIN TRY / END TRY / BEGIN CATCH / END CATCH` → `BEGIN ... EXCEPTION WHEN OTHERS THEN ... END`
- `IF XACT_STATE() <> 0 ROLLBACK` — omitted; PostgreSQL automatically rolls back on unhandled exception
- `THROW` → `RAISE`
- `Website.CalculateCustomerPrice(...)` → `website.calculate_customer_price(...)`
- `INNER JOIN @Orders AS o ON ol.OrderReference = o.OrderReference` → JSON element join via `->>` operator

## TODOs

- Callers (application layer) must serialize `OrderList` and `OrderLineList` TVPs as JSONB arrays before calling this function.
- Alternatively, convert the UDTs (Website.OrderList, Website.OrderLineList) to PostgreSQL composite types and use `UNNEST` — see `postgres/Website/Types/`.
- Verify `sequences.order_id_seq` exists: `/mssql-to-postgres wwi-ssdt/wwi-ssdt/Sequences/`

## Dependencies

| Object | Status |
|---|---|
| `sales.orders` | check postgres/Sales/Tables/Orders.sql |
| `sales.orderlines` | check postgres/Sales/Tables/OrderLines.sql |
| `warehouse.stockitems` | check postgres/Warehouse/Tables/StockItems.sql |
| `sequences.order_id_seq` | check postgres/Sequences/ |
| `website.calculate_customer_price` | postgres/Website/Functions/calculate_customer_price.sql ✓ |
