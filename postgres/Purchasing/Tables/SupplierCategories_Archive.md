# Conversion summary: SupplierCategories_Archive.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Purchasing/Tables/SupplierCategories_Archive.sql`
- **Output:** `postgres/Purchasing/Tables/SupplierCategories_Archive.sql`

## Conversions applied
- `[Purchasing].[SupplierCategories_Archive]` → `purchasing.supplier_categories_archive`
- `INT` → `INTEGER`
- `NVARCHAR(50)` → `VARCHAR(50)`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `CREATE CLUSTERED INDEX` → `CREATE INDEX` (MSSQL `WITH (DATA_COMPRESSION = PAGE)` omitted — no PostgreSQL equivalent)

No FK dependencies.
