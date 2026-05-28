# Conversion summary: DeliveryMethods_Archive.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Application/Tables/DeliveryMethods_Archive.sql`
- **Output:** `postgres/Application/Tables/DeliveryMethods_Archive.sql`

## Conversions applied
- `[Application].[DeliveryMethods_Archive]` → `application.delivery_methods_archive`
- `INT` → `INTEGER`
- `NVARCHAR(50)` → `VARCHAR(50)`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `CREATE CLUSTERED INDEX` → `CREATE INDEX`
- `WITH (DATA_COMPRESSION = PAGE)` → omitted
