# Conversion summary: SystemParameters.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Application/Tables/SystemParameters.sql`
- **Output:** `postgres/Application/Tables/SystemParameters.sql`

## Conversions applied
- `[Application].[SystemParameters]` → `application.system_parameters`
- `INT` → `INTEGER`
- `NVARCHAR(n)` → `VARCHAR(n)` (all address/code fields)
- `NVARCHAR(MAX)` → `TEXT` (ApplicationSettings)
- `[sys].[geography]` → `geography` (PostGIS) (DeliveryLocation)
- `NEXT VALUE FOR [Sequences].[SystemParameterID]` → `nextval('sequences.system_parameter_id_seq')`; sequence emitted
- Named-default constraints removed
- `DEFAULT (sysdatetime())` → `DEFAULT CURRENT_TIMESTAMP` (LastEditedWhen)
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`
- `CREATE NONCLUSTERED INDEX` → `CREATE INDEX` (2 indexes)
- 2 index-level extended properties → omitted
- 1 table-level + 11 column-level extended properties → `COMMENT ON TABLE` / `COMMENT ON COLUMN`

## Next files to convert (unresolved dependencies)

| Dependency | Required by (columns) | Run |
|---|---|---|
| `application.people` | `system_parameters.LastEditedBy` | `/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/People.sql` |
| `application.cities` | `system_parameters.DeliveryCityID, PostalCityID` | `/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/Cities.sql` |

## PostGIS note
This table uses PostGIS `geography` columns. Run `CREATE EXTENSION IF NOT EXISTS postgis;` before applying this file.
