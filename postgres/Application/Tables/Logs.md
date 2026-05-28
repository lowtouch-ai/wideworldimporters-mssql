# Conversion summary: Logs.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Application/Tables/Logs.sql`
- **Output:** `postgres/Application/Tables/Logs.sql`

## Conversions applied
- `[Application].[Logs]` → `application.logs`
- `NVARCHAR(4000)` → `VARCHAR(4000)`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `NVARCHAR(MAX)` → `TEXT`
- `CLUSTERED COLUMNSTORE INDEX` → omitted (no PostgreSQL equivalent)
- 1 index-level extended property → omitted
- 4 column-level and table-level extended properties → `COMMENT ON TABLE / COLUMN`
