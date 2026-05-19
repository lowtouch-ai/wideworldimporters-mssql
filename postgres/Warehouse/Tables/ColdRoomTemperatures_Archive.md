# Conversion summary: ColdRoomTemperatures_Archive.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Warehouse/Tables/ColdRoomTemperatures_Archive.sql`
- **Output:** `postgres/Warehouse/Tables/ColdRoomTemperatures_Archive.sql`

## Conversions applied
- `[Warehouse].[ColdRoomTemperatures_Archive]` → `warehouse.coldroomtemperatures_archive`
- `BIGINT` → `BIGINT` (unchanged)
- `INT` → `INTEGER`
- `DATETIME2(7)` → `TIMESTAMP(6)` (×4 columns)
- `DECIMAL(10, 2)` → `NUMERIC(10, 2)`
- `GO` statement separators removed
- `CREATE CLUSTERED INDEX` → `CREATE INDEX` (CLUSTERED not applicable in PostgreSQL)
- `WITH (DATA_COMPRESSION = PAGE)` stripped: no PostgreSQL equivalent

## Next files to convert (unresolved dependencies)

None — this table has no foreign key references.
