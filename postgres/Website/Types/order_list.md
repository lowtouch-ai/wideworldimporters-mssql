# Conversion summary: Website.OrderList

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Website/User Defined Types/OrderList.sql`
- **Output:** `postgres/Website/Types/order_list.sql`

## Type mapping
- **MSSQL:** `CREATE TYPE [Website].[OrderList] AS TABLE` (memory-optimized)
- **PostgreSQL:** `CREATE TYPE website.order_list AS` (composite type)

## Conversions applied
- `MEMORY_OPTIMIZED = ON` → removed (no PostgreSQL equivalent)
- `PRIMARY KEY NONCLUSTERED ([OrderReference] ASC)` → removed (composite types have no constraints)
- `INT NOT NULL / NULL` → `integer`
- `DATE` → `date`
- `NVARCHAR(20)` → `varchar(20)`
- `BIT NULL` → `boolean`
- `NVARCHAR(MAX) NULL` → `text`

## Calling convention change

**MSSQL (TVP):**
```sql
DECLARE @orders Website.OrderList;
INSERT INTO @orders VALUES (1, 42, 5, '2016-01-01', N'PO-001', 1, NULL, NULL);
EXEC Website.InsertOrdersLines @Orders = @orders, @SalespersonID = 1;
```

**PostgreSQL (composite type array):**
```sql
SELECT website.insert_orders_lines(
    p_orders := ARRAY[ROW(1, 42, 5, '2016-01-01', 'PO-001', true, NULL, NULL)::website.order_list],
    p_salesperson_id := 1
);
```

**PostgreSQL (jsonb — mssql-to-pgfunc default):**
```sql
SELECT website.insert_orders_lines(
    p_orders := '[{"OrderReference":1,"CustomerID":42,...}]'::jsonb,
    p_salesperson_id := 1
);
```

## TODOs
- `PRIMARY KEY NONCLUSTERED ([OrderReference] ASC)` removed — uniqueness of `OrderReference` within a batch must be validated in the consuming function if required.
