# record_vehicle_temperature

Converted from: `wwi-ssdt/wwi-ssdt/Website/Stored Procedures/RecordVehicleTemperature.sql`

## Summary

Parses a JSON array of vehicle temperature sensor readings and inserts them into `warehouse.vehicletemperatures`.

## Conversion notes

- `ISJSON(@FullSensorDataArray) = 0` → attempt `::jsonb` cast inside a `BEGIN/EXCEPTION` block
- `OPENJSON(@FullSensorDataArray, N'$.Recordings') WITH (col type N'$.path')` → `jsonb_array_elements(p_FullSensorDataArray::jsonb -> 'Recordings')` with `->>` path extraction
- `FullSensorData nvarchar(max) N'$' AS JSON` (whole element as JSON string) → `elem::text`
- `IsCompressed <> 0` → `false` literal for insert
- `@@ROWCOUNT` → `GET DIAGNOSTICS _rowcount = ROW_COUNT`
- `BEGIN TRY/CATCH` → `BEGIN ... EXCEPTION WHEN OTHERS THEN ...`
- `PRINT @HelpMessage` → `RAISE NOTICE`
- `THROW` → `RAISE EXCEPTION`
- `COMMIT` removed — PostgreSQL autocommit handles this at the calling transaction level

## Dependencies

| Object | Status |
|---|---|
| `warehouse.vehicletemperatures` | check postgres/Warehouse/Tables/VehicleTemperatures.sql |
