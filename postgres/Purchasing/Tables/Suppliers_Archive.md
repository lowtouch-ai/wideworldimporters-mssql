# Conversion summary: Suppliers_Archive.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Purchasing/Tables/Suppliers_Archive.sql`
- **Output:** `postgres/Purchasing/Tables/Suppliers_Archive.sql`

## Conversions applied
- `[Purchasing].[Suppliers_Archive]` → `purchasing.suppliers_archive`
- `INT` → `INTEGER`
- `NVARCHAR(n)` → `VARCHAR(n)` for all fixed-length columns
- `NVARCHAR(MAX)` → `TEXT`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `[sys].[geography]` → `geography` (PostGIS)
- `MASKED WITH (FUNCTION = 'default()')` clauses stripped — no PostgreSQL equivalent
- `CREATE CLUSTERED INDEX` → `CREATE INDEX` (MSSQL `WITH (DATA_COMPRESSION = PAGE)` omitted — no PostgreSQL equivalent)

No FK dependencies.

## PostGIS note
This table uses PostGIS `geography` columns. Run `CREATE EXTENSION IF NOT EXISTS postgis;` before applying this file.
