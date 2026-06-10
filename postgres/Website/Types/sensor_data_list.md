# sensor_data_list — Conversion Summary

## Source
`wwi-ssdt/wwi-ssdt/Website/User Defined Types/SensorDataList.sql`

## Output
`postgres/Website/Types/sensor_data_list.sql`

## Changes Made
- `CREATE TYPE [Website].[SensorDataList] AS TABLE (...)` → `CREATE TYPE website.sensor_data_list AS (...)`
- Stripped `PRIMARY KEY NONCLUSTERED` constraint
- Stripped `WITH (MEMORY_OPTIMIZED = ON)` clause
- `INT` → `INTEGER`
- `IDENTITY(1,1)` removed — composite types have no identity/serial columns; callers must supply the ID or use a sequence separately
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `DECIMAL(18, 2)` → `NUMERIC(18, 2)`
- `NOT NULL` / `NULL` annotations removed

## Calling Convention Change
In MSSQL, `SensorDataList` was a Table-Valued Parameter (TVP). The `IDENTITY` column means the caller did not supply `SensorDataListID`; in PostgreSQL, callers must assign IDs explicitly, or the function should generate them (e.g. via a sequence or `generate_series`).
In PostgreSQL, pass this data as a `JSONB` array and unpack with `jsonb_to_recordset()`, or use `website.sensor_data_list[]` and `unnest()`.
