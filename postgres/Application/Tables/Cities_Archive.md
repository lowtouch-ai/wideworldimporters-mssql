# Conversion summary: Cities_Archive.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Application/Tables/Cities_Archive.sql`
- **Output:** `postgres/Application/Tables/Cities_Archive.sql`

## Conversions applied
- `[Application].[Cities_Archive]` → `application.cities_archive`
- `INT` → `INTEGER`
- `NVARCHAR(50)` → `VARCHAR(50)`
- `[sys].[geography]` → `geography` (PostGIS)
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `CREATE CLUSTERED INDEX` → `CREATE INDEX`
- `WITH (DATA_COMPRESSION = PAGE)` → omitted

## PostGIS note
This table uses PostGIS `geography` columns. Run `CREATE EXTENSION IF NOT EXISTS postgis;` before applying this file.
