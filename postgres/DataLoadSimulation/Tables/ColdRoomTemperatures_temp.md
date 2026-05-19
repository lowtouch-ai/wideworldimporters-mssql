# Conversion summary: ColdRoomTemperatures_temp.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Tables/ColdRoomTemperatures_temp.sql`
- **Output:** `postgres/DataLoadSimulation/Tables/ColdRoomTemperatures_temp.sql`

## Conversions applied
- `DataLoadSimulation.[ColdRoomTemperatures_temp]` → `dataloadsimulation.coldroomtemperatures_temp`
- `BIGINT` → `BIGINT` (unchanged)
- `INT` → `INTEGER`
- `DATETIME2(7)` → `TIMESTAMP(6)` (×3 columns)
- `DECIMAL(10, 2)` → `NUMERIC(10, 2)`
- `WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_ONLY)` stripped: no PostgreSQL equivalent
- `NONCLUSTERED HASH ... WITH (BUCKET_COUNT=100000)` omitted: no PostgreSQL equivalent; replaced with a plain `CREATE INDEX`

## Next files to convert (unresolved dependencies)

None — this table has no foreign key references.
