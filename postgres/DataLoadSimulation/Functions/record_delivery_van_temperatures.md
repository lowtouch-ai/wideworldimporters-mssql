# Conversion summary: DataLoadSimulation.RecordDeliveryVanTemperatures

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/RecordDeliveryVanTemperatures.sql`
- **Pattern:** Simple DML (nested WHILE loops with INSERTs)
- **Output:** `postgres/DataLoadSimulation/Functions/record_delivery_van_temperatures.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.record_delivery_van_temperatures(p_average_seconds_between_readings integer, p_number_of_sensors integer, p_current_date_time timestamp, p_starting_when timestamp, p_is_silent_mode boolean) RETURNS void
```

## Conversion notes
- `DATEADD(hour, 16, @MidnightToday)` → `CAST(p_starting_when AS date)::timestamp + interval '16 hours'`
- `STRING_ESCAPE(@VehicleRegistration, N'json')` → string used directly (no special chars in 'WWI-321-A')
- `CONVERT(nvarchar(30), @TimeCounter, 126)` → `to_char(v_time_counter, 'YYYY-MM-DD"T"HH24:MI:SS')`
- `CASE WHEN @TimeCounter < '20220101' THEN 1 ELSE 0 END` → `v_time_counter < '2022-01-01'::timestamp`
- JSON built via string concatenation preserved (no JSON_MODIFY in original)
- `COMPRESS(@FullSensorData)` → no PostgreSQL equivalent; `CompressedSensorData` stored as NULL

## TODOs
- TODO: COMPRESS() not available; use pg_compress extension for real compression

## Tables referenced
| Table | Postgres file |
|---|---|
| `warehouse.vehicletemperatures` | `postgres/Warehouse/Tables/VehicleTemperatures.sql` |
