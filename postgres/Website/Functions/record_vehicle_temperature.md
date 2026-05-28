# Conversion summary: Website.RecordVehicleTemperature

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Website/Stored Procedures/RecordVehicleTemperature.sql`
- **Pattern:** JSON insert → `RETURNS void`
- **Output:** `postgres/Website/Functions/record_vehicle_temperature.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION website.record_vehicle_temperature(
    p_full_sensor_data_array text
) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@FullSensorDataArray nvarchar(1000)` | `p_full_sensor_data_array text` | text | JSON payload |

## Conversion notes
- `ISJSON(@FullSensorDataArray) = 0` → `BEGIN p_full_sensor_data_array::jsonb EXCEPTION WHEN invalid_text_representation THEN RAISE EXCEPTION`
- `OPENJSON(@FullSensorDataArray, N'$.Recordings') WITH (VehicleRegistration nvarchar(40) N'$.properties.rego', ...)` → `jsonb_array_elements(v_sensor_json->'Recordings') AS elem` with `elem->'properties'->>'rego'` for nested path extraction
- `FullSensorData nvarchar(max) N'$' AS JSON` (whole element as JSON) → `elem::text`
- `@@ROWCOUNT = 0` → `GET DIAGNOSTICS v_rowcount = ROW_COUNT`
- `BEGIN TRAN`/`COMMIT` removed — caller's transaction context
- `BEGIN TRY ... BEGIN CATCH` → `EXCEPTION WHEN OTHERS THEN`
- `XACT_ABORT ON`, `WITH EXECUTE AS OWNER` removed

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `warehouse.vehicletemperatures` | `postgres/Warehouse/Tables/VehicleTemperatures.sql` |
