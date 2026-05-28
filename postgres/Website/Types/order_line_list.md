# order_line_list — Conversion Summary

## Source
`wwi-ssdt/wwi-ssdt/Website/User Defined Types/OrderLineList.sql`

## Output
`postgres/Website/Types/order_line_list.sql`

## Changes Made
- `CREATE TYPE [Website].[OrderLineList] AS TABLE (...)` → `CREATE TYPE website.order_line_list AS (...)`
- Stripped `INDEX [IX_Website_OrderLineList]` clause (composite types have no indexes)
- Stripped `WITH (MEMORY_OPTIMIZED = ON)` clause
- `INT` → `INTEGER`
- `NVARCHAR(100)` → `VARCHAR(100)`
- `NULL` annotations removed (composite type fields have no nullability constraints)

## Calling Convention Change
In MSSQL, `OrderLineList` was a Table-Valued Parameter (TVP) passed directly to stored procedures.
In PostgreSQL, stored functions should accept this data as a `JSONB` array and unpack with `jsonb_to_recordset()`, or use `website.order_line_list[]` array parameter and unpack with `unnest()`.
