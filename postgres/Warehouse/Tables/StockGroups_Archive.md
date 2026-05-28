# Conversion summary: StockGroups_Archive.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Warehouse/Tables/StockGroups_Archive.sql`
- **Output:** `postgres/Warehouse/Tables/StockGroups_Archive.sql`

## Conversions applied
- `[Warehouse].[StockGroups_Archive]` → `warehouse.stock_groups_archive`
- `INT` → `INTEGER`
- `NVARCHAR(50)` → `VARCHAR(50)`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `CREATE CLUSTERED INDEX` → `CREATE INDEX` (MSSQL `WITH (DATA_COMPRESSION = PAGE)` omitted — no PostgreSQL equivalent)

No FK dependencies.
