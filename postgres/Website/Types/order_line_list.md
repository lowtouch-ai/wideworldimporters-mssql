# Conversion summary: Website.OrderLineList

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Website/User Defined Types/OrderLineList.sql`
- **Output:** `postgres/Website/Types/order_line_list.sql`

## Type mapping
- **MSSQL:** `CREATE TYPE [Website].[OrderLineList] AS TABLE` (memory-optimized)
- **PostgreSQL:** `CREATE TYPE website.order_line_list AS` (composite type)

## Conversions applied
- `MEMORY_OPTIMIZED = ON` → removed (no PostgreSQL equivalent)
- `INDEX [IX_Website_OrderLineList] ([OrderReference])` → removed (composite types have no indexes)
- `NVARCHAR(100)` → `varchar(100)`
- `INT NULL` → `integer` (nullability dropped — composite types have no constraints)

## Calling convention change

**MSSQL (TVP):**
```sql
DECLARE @lines Website.OrderLineList;
INSERT INTO @lines VALUES (1, 42, N'Widget', 10);
EXEC Website.InsertOrderLines @OrderLines = @lines;
```

**PostgreSQL (composite type array):**
```sql
SELECT website.insert_order_lines(
    p_order_lines := ARRAY[ROW(1, 42, 'Widget', 10)::website.order_line_list]
);
```

**PostgreSQL (jsonb — mssql-to-pgfunc default):**
```sql
SELECT website.insert_order_lines(
    p_order_lines := '[{"OrderReference":1,"StockItemID":42,"Description":"Widget","Quantity":10}]'::jsonb
);
```

## TODOs
- `INDEX [IX_Website_OrderLineList] ([OrderReference])` removed — if lookup by `OrderReference` is needed inside a consuming function, iterate the array directly.
