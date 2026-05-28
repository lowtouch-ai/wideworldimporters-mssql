# Conversion summary: TransactionTypes_Archive.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Application/Tables/TransactionTypes_Archive.sql`
- **Output:** `postgres/Application/Tables/TransactionTypes_Archive.sql`

## Conversions applied
- `[Application].[TransactionTypes_Archive]` → `application.transaction_types_archive`
- `INT` → `INTEGER`
- `NVARCHAR(50)` → `VARCHAR(50)`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `CREATE CLUSTERED INDEX` → `CREATE INDEX`
- `WITH (DATA_COMPRESSION = PAGE)` → omitted
