# order_id_list — Conversion Summary

## Source
`wwi-ssdt/wwi-ssdt/Website/User Defined Types/OrderIDList.sql`

## Output
`postgres/Website/Types/order_id_list.sql`

## Changes Made
- `CREATE TYPE [Website].[OrderIDList] AS TABLE (...)` → `CREATE TYPE website.order_id_list AS (...)`
- Stripped `PRIMARY KEY NONCLUSTERED` constraint (composite types have no constraints)
- Stripped `WITH (MEMORY_OPTIMIZED = ON)` clause
- `INT` → `INTEGER`
- `NOT NULL` removed (composite type fields have no nullability constraints)

## Calling Convention Change
In MSSQL, `OrderIDList` was a Table-Valued Parameter (TVP) passed directly to stored procedures.
In PostgreSQL, stored functions should accept this data as a `JSONB` array (e.g. `jsonb_array_elements`) or use `INTEGER[]` for simple ID lists, then process with `unnest()`.

The composite type is retained for completeness but may be replaced with `INTEGER[]` in practice.
