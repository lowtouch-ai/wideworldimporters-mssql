# Conversion summary: Cities.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Application/Tables/Cities.sql`
- **Output:** `postgres/Application/Tables/Cities.sql`

## Conversions applied
- `[Application].[Cities]` → `application.cities`
- `INT` → `INTEGER`
- `NVARCHAR(50)` → `VARCHAR(50)`
- `[sys].[geography]` → `geography` (PostGIS)
- `NEXT VALUE FOR [Sequences].[CityID]` → `nextval('sequences.city_id_seq')` + `CREATE SEQUENCE` emitted
- Temporal table handling: `GENERATED ALWAYS AS ROW START/END` → `TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP`; `PERIOD FOR SYSTEM_TIME` and `SYSTEM_VERSIONING` clauses removed
- Named-default constraint syntax removed
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`
- 1 `CREATE NONCLUSTERED INDEX` → `CREATE INDEX`
- 1 index-level extended property → omitted
- 5 column-level and table-level extended properties → `COMMENT ON TABLE / COLUMN`

## PostGIS note
This table uses PostGIS `geography` columns. Run `CREATE EXTENSION IF NOT EXISTS postgis;` before applying this file.
