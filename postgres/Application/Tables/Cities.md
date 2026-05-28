# Conversion summary: Cities.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Application/Tables/Cities.sql`
- **Output:** `postgres/Application/Tables/Cities.sql`

## Conversions applied
- `[Application].[Cities]` → `application.cities`
- `INT` → `INTEGER`
- `NVARCHAR(50)` → `VARCHAR(50)`
- `[sys].[geography]` → `geography` (PostGIS)
- `NEXT VALUE FOR [Sequences].[CityID]` → `nextval('sequences.city_id_seq')`; sequence emitted
- Named-default constraint removed
- `GENERATED ALWAYS AS ROW START` / `GENERATED ALWAYS AS ROW END` → `TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP`
- `PERIOD FOR SYSTEM_TIME (...)` / `WITH (SYSTEM_VERSIONING = ON ...)` removed
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`
- `CREATE NONCLUSTERED INDEX` → `CREATE INDEX` (1 index)
- 1 index-level extended property → omitted
- 1 table-level + 5 column-level extended properties → `COMMENT ON TABLE` / `COMMENT ON COLUMN`

## Next files to convert (unresolved dependencies)

| Dependency | Required by (columns) | Run |
|---|---|---|
| `application.people` | `cities.LastEditedBy` | `/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/People.sql` |
| `application.state_provinces` | `cities.StateProvinceID` | `/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/StateProvinces.sql` |

## PostGIS note
This table uses PostGIS `geography` columns. Run `CREATE EXTENSION IF NOT EXISTS postgis;` before applying this file.
