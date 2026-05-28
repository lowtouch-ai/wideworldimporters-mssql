# Conversion summary: Colors_Archive.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Warehouse/Tables/Colors_Archive.sql`
- **Output:** `postgres/Warehouse/Tables/Colors_Archive.sql`

## Conversions applied
- `[Warehouse].[Colors_Archive]` → `warehouse.colors_archive`
- `INT` → `INTEGER`
- `NVARCHAR(20)` → `VARCHAR(20)`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `CREATE CLUSTERED INDEX` → `CREATE INDEX` (MSSQL `WITH (DATA_COMPRESSION = PAGE)` omitted — no PostgreSQL equivalent)

No FK dependencies.
