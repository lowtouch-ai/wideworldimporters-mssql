# Conversion summary: People_Archive.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Application/Tables/People_Archive.sql`
- **Output:** `postgres/Application/Tables/People_Archive.sql`

## Conversions applied
- `[Application].[People_Archive]` → `application.people_archive`
- `INT` → `INTEGER`
- `NVARCHAR(n)` → `VARCHAR(n)` or `TEXT` for MAX
- `VARBINARY(MAX)` → `BYTEA`
- `BIT` → `BOOLEAN`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `NVARCHAR(MAX)` → `TEXT`
- `CREATE CLUSTERED INDEX` → `CREATE INDEX`
- `WITH (DATA_COMPRESSION = PAGE)` → omitted
- In archive, SearchName is a plain `VARCHAR(101)` (already materialized), OtherLanguages is `TEXT`
