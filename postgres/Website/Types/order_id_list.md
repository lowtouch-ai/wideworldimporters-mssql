# Conversion summary: Website.OrderIDList

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Website/User Defined Types/OrderIDList.sql`
- **Output:** `postgres/Website/Types/order_id_list.sql`

## Type mapping
- **MSSQL:** `CREATE TYPE [Website].[OrderIDList] AS TABLE` (memory-optimized)
- **PostgreSQL:** `CREATE TYPE website.order_id_list AS` (composite type)

## Conversions applied
- `MEMORY_OPTIMIZED = ON` → removed (no PostgreSQL equivalent)
- `PRIMARY KEY NONCLUSTERED ([OrderID] ASC)` → removed (composite types have no constraints)
- `INT NOT NULL` → `integer` (nullability dropped — composite types have no constraints)

## Calling convention change

**MSSQL (TVP):**
```sql
DECLARE @ids Website.OrderIDList;
INSERT INTO @ids VALUES (1), (2), (3);
EXEC Website.SomeProcedure @OrderIDs = @ids;
```

**PostgreSQL (composite type array):**
```sql
SELECT website.some_function(
    p_order_ids := ARRAY[ROW(1)::website.order_id_list, ROW(2)::website.order_id_list]
);
```

**PostgreSQL (jsonb — mssql-to-pgfunc default):**
```sql
SELECT website.some_function(
    p_order_ids := '[{"OrderID":1},{"OrderID":2}]'::jsonb
);
```

> The `mssql-to-pgfunc` skill rewrites TVP parameters to `jsonb`. This composite type serves as the formal schema contract.

## Single-column note
`OrderIDList` has a single `integer` column. PostgreSQL callers may prefer `integer[]` directly instead of `website.order_id_list[]`. Both are valid; choose based on whether strict typing or brevity matters more.

## TODOs
- `PRIMARY KEY NONCLUSTERED` removed — no enforcement on the composite type; enforce uniqueness in the consuming function if needed.
