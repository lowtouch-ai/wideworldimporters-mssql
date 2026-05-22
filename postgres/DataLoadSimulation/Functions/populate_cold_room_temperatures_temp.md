# Conversion summary: DataLoadSimulation.PopulateColdRoomTemperatures_temp

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/PopulateColdRoomTemperatures_temp.sql`
- **Pattern:** Simple DML (WHILE loop with INSERTs)
- **Output:** `postgres/DataLoadSimulation/Functions/populate_cold_room_temperatures_temp.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.populate_cold_room_temperatures_temp(p_average_seconds_between_readings integer, p_number_of_sensors integer, p_time_counter timestamp, p_end_time timestamp) RETURNS void
```

## Conversion notes
- `WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER` → removed
- `BEGIN ATOMIC WITH (TRANSACTION ISOLATION LEVEL=SNAPSHOT, LANGUAGE=N'English')` → standard `BEGIN`
- `ISNULL(MAX(ColdRoomTemperatureID), 0) + 1` → `COALESCE(MAX("ColdRoomTemperatureID"), 0) + 1`
- `DATEADD(second, @DelayInSeconds, @TimeCounter)` → `v_time_counter + v_delay_in_seconds * interval '1 second'`
- `@ColdRoomTemperatureID += 1` → `v_cold_room_temperature_id := v_cold_room_temperature_id + 1`

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `dataloadsimulation.coldrooomtemperatures_temp` | `postgres/DataLoadSimulation/Tables/ColdRoomTemperatures_temp.sql` |
