# Conversion summary: Integration.GetCityUpdates

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetCityUpdates.sql`
- **Pattern:** Complex / cursor / temporal
- **Output:** `postgres/Integration/Functions/get_city_updates.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION integration.get_city_updates(
    p_last_cutoff timestamp,
    p_new_cutoff  timestamp
) RETURNS TABLE(
    "WWI City ID" integer, "City" varchar(50), "State Province" varchar(50),
    "Country" varchar(50), "Continent" varchar(30), "Sales Territory" varchar(50),
    "Region" varchar(30), "Subregion" varchar(30), "Location" geography,
    "Latest Recorded Population" bigint, "Valid From" timestamp, "Valid To" timestamp
)
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@LastCutoff datetime2(7)` | `p_last_cutoff timestamp` | timestamp | Lower bound (exclusive) |
| `@NewCutoff datetime2(7)` | `p_new_cutoff timestamp` | timestamp | Upper bound (inclusive) |

## Conversion notes
- `DECLARE @EndOfTime datetime2(7) = '99991231 23:59:59.9999999'` → `_end_of_time timestamp := '9999-12-31 23:59:59.9999999'`
- `DECLARE @InitialLoadDate date = '20200101'` → `_initial_load_date date := '2020-01-01'`
- `co.ValidFrom <> @InitialLoadDate` (datetime2 vs date implicit comparison) → `co.ValidFrom::date <> _initial_load_date`
- 3 MSSQL cursors converted to sequential FOR loops reusing `rec` (valid in PL/pgSQL since loops are sequential)
- `CREATE TABLE #CityChanges` → `DROP TABLE IF EXISTS citychanges; CREATE TEMP TABLE citychanges (...)`
- `[Location] geography` column in temp table and RETURNS TABLE → `geography` (PostGIS type)
- `[Location] geography` in final MSSQL SELECT (column alias used for DW ETL) → `cc."Location"` in RETURN QUERY (column name from RETURNS TABLE definition)
- Cursor 1 (CountryChangeList): excludes initial load date; Cities and StateProvinces use `DISTINCT ON (PK)` full snapshots; filtered by `co.CountryID = rec.countryid`
- Cursor 2 (StateProvinceChangeList): excludes initial load date; Cities and StateProvinces use `DISTINCT ON (PK)` full snapshots; filtered by `sp.StateProvinceID = rec.stateprovinceid`
- Cursor 3 (CityChangeList): includes initial load; Cities subquery uses `LIMIT 1 ORDER BY ValidFrom DESC` filtered by `CityID = rec.cityid`; StateProvinces and Countries still use `DISTINCT ON` snapshots; filtered by `c.CityID = rec.cityid`
- INSERT uses `rec.validfrom, NULL` for "Valid From"/"Valid To" (cursor's ValidFrom, not c.ValidFrom)
- `CREATE INDEX IX_CityChanges` → `CREATE INDEX ix_citychanges`
- `UPDATE cc SET … FROM #CityChanges AS cc` → `UPDATE citychanges AS cc SET …`
- Final SELECT → `RETURN QUERY SELECT … FROM citychanges`
- `RETURN 0` (end of SP) → removed (void return not applicable in TABLE-returning function)

## TODOs
- **FOR SYSTEM_TIME AS OF rec.validfrom (3 temporal tables: Cities, StateProvinces, Countries)** — Not natively supported in PostgreSQL. Approximation uses `DISTINCT ON (PK) ORDER BY PK, ValidFrom DESC` over `(archive_range UNION ALL current_table)` for Cities/StateProvinces (multi-entity cursors 1 and 2) and `LIMIT 1 ORDER BY ValidFrom DESC` for Cities in cursor 3 (single-entity). Verify deduplication correctness for edge cases where both archive and current rows match a given timestamp.

## Tables referenced
| Table | Postgres file |
|---|---|
| `application.countries_archive` | `postgres/Application/Tables/Countries_Archive.sql` |
| `application.countries` | `postgres/Application/Tables/Countries.sql` |
| `application.stateprovinces_archive` | `postgres/Application/Tables/StateProvinces_Archive.sql` |
| `application.stateprovinces` | `postgres/Application/Tables/StateProvinces.sql` |
| `application.cities_archive` | `postgres/Application/Tables/Cities_Archive.sql` |
| `application.cities` | `postgres/Application/Tables/Cities.sql` |
