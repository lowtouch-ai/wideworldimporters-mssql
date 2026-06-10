# Conversion summary: StateProvinces.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Application/Tables/StateProvinces.sql`
- **Output:** `postgres/Application/Tables/StateProvinces.sql`

## Conversions applied
- `[Application].[StateProvinces]` → `application.stateprovinces`
- `INT` → `INTEGER`
- `NVARCHAR(n)` → `VARCHAR(n)`
- `[sys].[geography]` → `geography` (PostGIS)
- `NEXT VALUE FOR [Sequences].[StateProvinceID]` → `nextval('sequences.state_province_id_seq')` + `CREATE SEQUENCE` emitted
- Temporal table handling: `GENERATED ALWAYS AS ROW START/END` → `TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP`; `PERIOD FOR SYSTEM_TIME` and `SYSTEM_VERSIONING` clauses removed
- Named-default constraint syntax removed
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`
- `UNIQUE NONCLUSTERED` → `UNIQUE`
- 2 `CREATE NONCLUSTERED INDEX` → `CREATE INDEX`
- 2 index-level extended properties → omitted
- 8 column-level and table-level extended properties → `COMMENT ON TABLE / COLUMN`

## PostGIS note
This table uses PostGIS `geography` columns. Run `CREATE EXTENSION IF NOT EXISTS postgis;` before applying this file.
