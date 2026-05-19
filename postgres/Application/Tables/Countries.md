# Conversion summary: Countries.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Application/Tables/Countries.sql`
- **Output:** `postgres/Application/Tables/Countries.sql`

## Conversions applied
- `[Application].[Countries]` → `application.countries`
- `INT` → `INTEGER`
- `NVARCHAR(n)` → `VARCHAR(n)`
- `[sys].[geography]` → `geography` (PostGIS)
- `NEXT VALUE FOR [Sequences].[CountryID]` → `nextval('sequences.country_id_seq')` + `CREATE SEQUENCE` emitted
- Temporal table handling: `GENERATED ALWAYS AS ROW START/END` → `TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP`; `PERIOD FOR SYSTEM_TIME` and `SYSTEM_VERSIONING` clauses removed
- Named-default constraint syntax removed
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`
- `UNIQUE NONCLUSTERED` → `UNIQUE`
- 12 column-level and table-level extended properties → `COMMENT ON TABLE / COLUMN`

## PostGIS note
This table uses PostGIS `geography` columns. Run `CREATE EXTENSION IF NOT EXISTS postgis;` before applying this file.
