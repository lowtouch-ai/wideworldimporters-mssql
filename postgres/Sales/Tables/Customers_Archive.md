# Conversion summary: Customers_Archive.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sales/Tables/Customers_Archive.sql`
- **Output:** `postgres/Sales/Tables/Customers_Archive.sql`

## Conversions applied
- `[Sales].[Customers_Archive]` → `sales.customers_archive`
- `INT` → `INTEGER`
- `NVARCHAR(100)` → `VARCHAR(100)`, `NVARCHAR(20)` → `VARCHAR(20)`, `NVARCHAR(5)` → `VARCHAR(5)`, `NVARCHAR(256)` → `VARCHAR(256)`, `NVARCHAR(60)` → `VARCHAR(60)`, `NVARCHAR(10)` → `VARCHAR(10)`
- `DECIMAL(18,2)` → `NUMERIC(18,2)`, `DECIMAL(18,3)` → `NUMERIC(18,3)`
- `BIT` → `BOOLEAN`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `[sys].[geography]` → `geography` (PostGIS)
- `CREATE CLUSTERED INDEX ... WITH (DATA_COMPRESSION = PAGE)` → `CREATE INDEX` (DATA_COMPRESSION clause dropped)
- No foreign keys (archive table)

## PostGIS note
This table uses PostGIS `geography` columns. Run `CREATE EXTENSION IF NOT EXISTS postgis;` before applying this file.
