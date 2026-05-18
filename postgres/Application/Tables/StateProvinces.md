# Conversion summary: StateProvinces.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Application/Tables/StateProvinces.sql`
- **Output:** `postgres/Application/Tables/StateProvinces.sql`

## Conversions applied
- `[Application].[StateProvinces]` → `application.state_provinces`
- `INT` → `INTEGER`
- `NVARCHAR(n)` → `VARCHAR(n)`
- `[sys].[geography]` → `geography` (PostGIS)
- `NEXT VALUE FOR [Sequences].[StateProvinceID]` → `nextval('sequences.state_province_id_seq')`; sequence emitted
- Named-default constraint removed
- `GENERATED ALWAYS AS ROW START` / `GENERATED ALWAYS AS ROW END` → `TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP`
- `PERIOD FOR SYSTEM_TIME (...)` / `WITH (SYSTEM_VERSIONING = ON ...)` removed
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`; `UNIQUE NONCLUSTERED` → `UNIQUE`
- `CREATE NONCLUSTERED INDEX` → `CREATE INDEX` (2 indexes)
- 2 index-level extended properties → omitted
- 1 table-level + 7 column-level extended properties → `COMMENT ON TABLE` / `COMMENT ON COLUMN`

## Next files to convert (unresolved dependencies)

| Dependency | Required by (columns) | Run |
|---|---|---|
| `application.people` | `state_provinces.LastEditedBy` | `/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/People.sql` |
| `application.countries` | `state_provinces.CountryID` | `/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/Countries.sql` |

## PostGIS note
This table uses PostGIS `geography` columns. Run `CREATE EXTENSION IF NOT EXISTS postgis;` before applying this file.
