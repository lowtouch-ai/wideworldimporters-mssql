# get_city_updates

Converted from: `wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetCityUpdates.sql`

## Summary

Returns a changelog of city dimension records (with denormalized state/province and country data) that changed within the given cutoff window. Used to feed incremental loads into a data warehouse.

## Conversion notes

- `FOR SYSTEM_TIME AS OF @ValidFrom` — not supported in PostgreSQL. Rewritten as `UNION ALL` of archive table + current table filtered by `ValidFrom <= @ValidFrom AND (ValidTo > @ValidFrom OR ValidTo IS NULL)`.
- `CREATE TABLE #CityChanges` → `CREATE TEMP TABLE _city_changes ... ON COMMIT DROP`
- `DECLARE ... CURSOR FAST_FORWARD READ_ONLY FOR ... OPEN / FETCH / WHILE @@FETCH_STATUS = 0` → `FOR _var IN SELECT ... LOOP`
- `CLOSE / DEALLOCATE` removed (no cursor objects in PL/pgSQL FOR loop)
- `CREATE INDEX IX_CityChanges ON #CityChanges (...)` → omitted (temp table is session-local; add if needed for performance)
- `datetime2(7)` → `timestamp(6)`
- `'99991231 23:59:59.9999999'` → `'9999-12-31 23:59:59.999999'`
- `geography` column preserved (requires PostGIS)
- `[Location] geography` in SELECT list (type annotation) → removed; column already typed

## TODOs

- Verify archive tables exist: `application.cities_archive`, `application.stateprovinces_archive`, `application.countries_archive`
- Archive tables must have `ValidFrom` and `ValidTo` columns (copied from the temporal table pattern)
- The `ValidTo IS NULL` condition for archive rows covers the case where the archive table doesn't set `ValidTo` on the last-known row; adjust if schema differs

## Dependencies

| Object | Status |
|---|---|
| `application.cities` | check postgres/Application/Tables/Cities.sql |
| `application.cities_archive` | check archive table DDL |
| `application.stateprovinces` | check postgres/Application/Tables/StateProvinces.sql |
| `application.stateprovinces_archive` | check archive table DDL |
| `application.countries` | check postgres/Application/Tables/Countries.sql |
| `application.countries_archive` | check archive table DDL |
