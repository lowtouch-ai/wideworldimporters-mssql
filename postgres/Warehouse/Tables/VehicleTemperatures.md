# Conversion summary: VehicleTemperatures.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Warehouse/Tables/VehicleTemperatures.sql`
- **Output:** `postgres/Warehouse/Tables/VehicleTemperatures.sql`

## Conversions applied
- `[Warehouse].[VehicleTemperatures]` → `warehouse.vehicletemperatures`
- `BIGINT IDENTITY (1, 1)` → `BIGINT GENERATED ALWAYS AS IDENTITY`
- `NVARCHAR(20)` → `VARCHAR(20)`, `NVARCHAR(1000)` → `VARCHAR(1000)`
- `INT` → `INTEGER`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `DECIMAL(10, 2)` → `NUMERIC(10, 2)`
- `BIT` → `BOOLEAN`
- `VARBINARY(MAX)` → `BYTEA`
- `COLLATE Latin1_General_CI_AS` stripped (×2 columns): use database-level collation in PostgreSQL
- `WITH (MEMORY_OPTIMIZED = ON)` stripped: no PostgreSQL equivalent
- `PRIMARY KEY NONCLUSTERED` → `PRIMARY KEY`

## Next files to convert (unresolved dependencies)

None — this table has no foreign key references.
