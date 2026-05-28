# order_list — Conversion Summary

## Source
`wwi-ssdt/wwi-ssdt/Website/User Defined Types/OrderList.sql`

## Output
`postgres/Website/Types/order_list.sql`

## Changes Made
- `CREATE TYPE [Website].[OrderList] AS TABLE (...)` → `CREATE TYPE website.order_list AS (...)`
- Stripped `PRIMARY KEY NONCLUSTERED` constraint
- Stripped `WITH (MEMORY_OPTIMIZED = ON)` clause
- `INT` → `INTEGER`
- `NVARCHAR(20)` → `VARCHAR(20)`
- `BIT` → `BOOLEAN`
- `NVARCHAR(MAX)` → `TEXT`
- `NOT NULL` / `NULL` annotations removed (composite type fields have no nullability constraints)

## Calling Convention Change
In MSSQL, `OrderList` was a Table-Valued Parameter (TVP) passed directly to stored procedures.
In PostgreSQL, stored functions should accept this data as a `JSONB` array and unpack with `jsonb_to_recordset()`, or use `website.order_list[]` array parameter and unpack with `unnest()`.
