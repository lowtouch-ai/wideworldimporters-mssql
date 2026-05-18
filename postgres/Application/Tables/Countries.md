# Conversion summary: Countries.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Application/Tables/Countries.sql`
- **Output:** `postgres/Application/Tables/Countries.sql`

## Conversions applied
- `[Application].[Countries]` → `application.countries`
- `INT` → `INTEGER`
- `NVARCHAR(n)` → `VARCHAR(n)` (CountryName, FormalName, IsoAlpha3Code, CountryType, Continent, Region, Subregion)
- `[sys].[geography]` → `geography` (PostGIS); `CREATE EXTENSION IF NOT EXISTS postgis;` prepended
- `NEXT VALUE FOR [Sequences].[CountryID]` → `nextval('sequences.country_id_seq')`; `CREATE SEQUENCE IF NOT EXISTS sequences.country_id_seq START 242 INCREMENT 1;` prepended
- Named-default constraint `CONSTRAINT [DF_...]` removed; `DEFAULT (...)` retained as `DEFAULT ...`
- `GENERATED ALWAYS AS ROW START` / `GENERATED ALWAYS AS ROW END` → `TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP` (temporal table handling)
- `PERIOD FOR SYSTEM_TIME (...)` clause removed
- `WITH (SYSTEM_VERSIONING = ON ...)` clause removed
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`
- `UNIQUE NONCLUSTERED` → `UNIQUE`
- 1 table-level extended property → `COMMENT ON TABLE`
- 11 column-level extended properties → `COMMENT ON COLUMN`

## Next files to convert (unresolved dependencies)

| Dependency | Required by (columns) | Run |
|---|---|---|
| `application.people` | `countries.LastEditedBy` | `/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/People.sql` |

## PostGIS note
This table uses PostGIS `geography` columns. Run `CREATE EXTENSION IF NOT EXISTS postgis;` before applying this file.
