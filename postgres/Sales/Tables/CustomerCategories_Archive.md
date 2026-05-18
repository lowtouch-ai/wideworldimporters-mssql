# Conversion summary: CustomerCategories_Archive.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sales/Tables/CustomerCategories_Archive.sql`
- **Output:** `postgres/Sales/Tables/CustomerCategories_Archive.sql`

## Conversions applied
- `[Sales].[CustomerCategories_Archive]` → `sales.customer_categories_archive`
- `INT` → `INTEGER`
- `NVARCHAR(50)` → `VARCHAR(50)`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `CREATE CLUSTERED INDEX` → `CREATE INDEX` (MSSQL `WITH (DATA_COMPRESSION = PAGE)` omitted — no PostgreSQL equivalent)

No FK dependencies.
