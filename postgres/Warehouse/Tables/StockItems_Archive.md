# Conversion summary: StockItems_Archive.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Warehouse/Tables/StockItems_Archive.sql`
- **Output:** `postgres/Warehouse/Tables/StockItems_Archive.sql`

## Conversions applied
- `[Warehouse].[StockItems_Archive]` → `warehouse.stockitems_archive`
- `INT` → `INTEGER`
- `NVARCHAR(100)` → `VARCHAR(100)`, `NVARCHAR(50)` → `VARCHAR(50)`, `NVARCHAR(20)` → `VARCHAR(20)`
- `NVARCHAR(MAX)` → `TEXT`
- `BIT` → `BOOLEAN`
- `DECIMAL(18,3)` → `NUMERIC(18,3)`, `DECIMAL(18,2)` → `NUMERIC(18,2)`
- `VARBINARY(MAX)` → `BYTEA`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `CREATE CLUSTERED INDEX ... WITH (DATA_COMPRESSION = PAGE)` → `CREATE INDEX` (DATA_COMPRESSION clause dropped)
- No foreign keys (archive table)
