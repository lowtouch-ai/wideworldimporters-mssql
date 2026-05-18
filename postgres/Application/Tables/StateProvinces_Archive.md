# Conversion summary: StateProvinces_Archive.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Application/Tables/StateProvinces_Archive.sql`
- **Output:** `postgres/Application/Tables/StateProvinces_Archive.sql`

## Conversions applied
- `[Application].[StateProvinces_Archive]` → `application.state_provinces_archive`
- `INT` → `INTEGER`
- `NVARCHAR(n)` → `VARCHAR(n)`
- `[sys].[geography]` → `geography` (PostGIS)
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `CREATE CLUSTERED INDEX` → `CREATE INDEX`
- `WITH (DATA_COMPRESSION = PAGE)` → omitted

## PostGIS note
This table uses PostGIS `geography` columns. Run `CREATE EXTENSION IF NOT EXISTS postgis;` before applying this file.
