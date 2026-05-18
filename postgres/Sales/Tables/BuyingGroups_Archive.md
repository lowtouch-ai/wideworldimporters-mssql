# Conversion summary: BuyingGroups_Archive.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sales/Tables/BuyingGroups_Archive.sql`
- **Output:** `postgres/Sales/Tables/BuyingGroups_Archive.sql`

## Conversions applied
- `[Sales].[BuyingGroups_Archive]` → `sales.buying_groups_archive`
- `INT` → `INTEGER`
- `NVARCHAR(50)` → `VARCHAR(50)`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `CREATE CLUSTERED INDEX` → `CREATE INDEX` (MSSQL `WITH (DATA_COMPRESSION = PAGE)` omitted — no PostgreSQL equivalent)

## Next files to convert (unresolved dependencies)

No FK dependencies.
