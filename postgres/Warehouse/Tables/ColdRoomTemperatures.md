# Conversion summary: ColdRoomTemperatures.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Warehouse/Tables/ColdRoomTemperatures.sql`
- **Output:** `postgres/Warehouse/Tables/ColdRoomTemperatures.sql`

## Conversions applied
- `[Warehouse].[ColdRoomTemperatures]` → `warehouse.coldroomtemperatures`
- `BIGINT IDENTITY (1, 1)` → `BIGINT GENERATED ALWAYS AS IDENTITY`
- `INT` → `INTEGER`
- `DATETIME2(7)` → `TIMESTAMP(6)` (×4 columns)
- `DECIMAL(10, 2)` → `NUMERIC(10, 2)`
- `WITH (MEMORY_OPTIMIZED = ON, SYSTEM_VERSIONING = ON (...))` stripped: no PostgreSQL equivalent
- `PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)` removed
- `GENERATED ALWAYS AS ROW START` / `GENERATED ALWAYS AS ROW END` → `TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP`
- `PRIMARY KEY NONCLUSTERED` → `PRIMARY KEY`
- `CREATE NONCLUSTERED INDEX` → `CREATE INDEX`

## Next files to convert (unresolved dependencies)

None — this table has no foreign key references.
