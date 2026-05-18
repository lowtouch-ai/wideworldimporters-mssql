# Conversion summary: Countries_Archive.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Application/Tables/Countries_Archive.sql`
- **Output:** `postgres/Application/Tables/Countries_Archive.sql`

## Conversions applied
- `[Application].[Countries_Archive]` → `application.countries_archive`
- `INT` → `INTEGER`
- `NVARCHAR(n)` → `VARCHAR(n)`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `[sys].[geography]` → `geography` (PostGIS)
- `CREATE CLUSTERED INDEX` → `CREATE INDEX` (CLUSTERED has no PostgreSQL equivalent; plain index emitted)
- `WITH (DATA_COMPRESSION = PAGE)` → omitted (no PostgreSQL equivalent)

## PostGIS note
This table uses PostGIS `geography` columns. Run `CREATE EXTENSION IF NOT EXISTS postgis;` before applying this file.
