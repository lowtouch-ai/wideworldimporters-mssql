# Conversion summary: PackageTypes_Archive.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Warehouse/Tables/PackageTypes_Archive.sql`
- **Output:** `postgres/Warehouse/Tables/PackageTypes_Archive.sql`

## Conversions applied
- `[Warehouse].[PackageTypes_Archive]` → `warehouse.package_types_archive`
- `INT` → `INTEGER`
- `NVARCHAR(50)` → `VARCHAR(50)`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `CREATE CLUSTERED INDEX` → `CREATE INDEX` (MSSQL `WITH (DATA_COMPRESSION = PAGE)` omitted — no PostgreSQL equivalent)

No FK dependencies.
