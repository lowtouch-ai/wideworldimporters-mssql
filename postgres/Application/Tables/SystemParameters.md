# Conversion summary: SystemParameters.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Application/Tables/SystemParameters.sql`
- **Output:** `postgres/Application/Tables/SystemParameters.sql`

## Conversions applied
- `[Application].[SystemParameters]` → `application.systemparameters`
- `INT` → `INTEGER`
- `NVARCHAR(n)` → `VARCHAR(n)`
- `NVARCHAR(MAX)` → `TEXT`
- `[sys].[geography]` → `geography` (PostGIS)
- `NEXT VALUE FOR [Sequences].[SystemParameterID]` → `nextval('sequences.system_parameter_id_seq')` + `CREATE SEQUENCE` emitted
- `DEFAULT (sysdatetime())` → `DEFAULT CURRENT_TIMESTAMP`
- Named-default constraint syntax removed
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`
- 2 `CREATE NONCLUSTERED INDEX` → `CREATE INDEX`
- 2 index-level extended properties → omitted
- 12 column-level and table-level extended properties → `COMMENT ON TABLE / COLUMN`

## PostGIS note
This table uses PostGIS `geography` columns. Run `CREATE EXTENSION IF NOT EXISTS postgis;` before applying this file.
