# get_employee_updates

Converted from: `wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetEmployeeUpdates.sql`

## Summary

Returns a changelog of employee records within the cutoff window for DW incremental loads.

## Conversion notes

- `FOR SYSTEM_TIME AS OF` → UNION ALL of archive + current with ValidFrom/ValidTo range
- MSSQL CURSOR → PL/pgSQL FOR loop
- `bit` → `boolean` for `IsSalesperson`, `IsEmployee`
- `varbinary(max)` → `bytea` for `Photo`
- `datetime2(7)` → `timestamp(6)`

## Dependencies

| Object | Status |
|---|---|
| `application.people` + `application.people_archive` | check postgres/Application/Tables/ |
