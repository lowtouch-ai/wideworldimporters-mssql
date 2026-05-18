# Conversion summary: Logs.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Application/Tables/Logs.sql`
- **Output:** `postgres/Application/Tables/Logs.sql`

## Conversions applied
- `[Application].[Logs]` → `application.logs`
- `NVARCHAR(4000)` → `VARCHAR(4000)` (Message)
- `NVARCHAR(MAX)` → `TEXT` (LogEvent)
- `DATETIME2(7)` → `TIMESTAMP(6)` (EventTime)
- `INDEX CCX_Application_Logs CLUSTERED COLUMNSTORE` → omitted with comment (no PostgreSQL equivalent)
- 1 index-level extended property → omitted (COLUMNSTORE index was omitted)
- 1 table-level + 4 column-level extended properties → `COMMENT ON TABLE` / `COMMENT ON COLUMN`
