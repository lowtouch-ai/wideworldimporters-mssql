# Conversion summary: PaymentMethods_Archive.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Application/Tables/PaymentMethods_Archive.sql`
- **Output:** `postgres/Application/Tables/PaymentMethods_Archive.sql`

## Conversions applied
- `[Application].[PaymentMethods_Archive]` → `application.payment_methods_archive`
- `INT` → `INTEGER`
- `NVARCHAR(50)` → `VARCHAR(50)`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `CREATE CLUSTERED INDEX` → `CREATE INDEX`
- `WITH (DATA_COMPRESSION = PAGE)` → omitted
