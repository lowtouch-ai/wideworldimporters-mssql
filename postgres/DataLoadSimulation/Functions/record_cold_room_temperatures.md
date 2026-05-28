# Conversion summary: DataLoadSimulation.RecordColdRoomTemperatures

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/RecordColdRoomTemperatures.sql`
- **Pattern:** Complex DML (DELETE...OUTPUT INTO pattern)
- **Output:** `postgres/DataLoadSimulation/Functions/record_cold_room_temperatures.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.record_cold_room_temperatures(p_average_seconds_between_readings integer, p_number_of_sensors integer, p_current_date_time timestamp, p_end_of_time timestamp, p_is_silent_mode boolean) RETURNS void
```

## Conversion notes
- `WITH (SNAPSHOT)` table hints removed (no PostgreSQL equivalent)
- `DELETE ... WITH (SNAPSHOT) OUTPUT deleted.* INTO table` → CTE with `DELETE ... RETURNING` + `INSERT`
- `DATEADD(second, -30, DATEADD(day, 1, @TimeCounter))` → `+ interval '1 day' - interval '30 seconds'`
- `EXEC DataLoadSimulation.PopulateColdRoomTemperatures_temp` → `PERFORM dataloadsimulation.populate_cold_room_temperatures_temp(...)`

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `dataloadsimulation.coldrooomtemperatures_temp` | `postgres/DataLoadSimulation/Tables/ColdRoomTemperatures_temp.sql` |
| `warehouse.coldrooomtemperatures` | `postgres/Warehouse/Tables/ColdRoomTemperatures.sql` |
| `warehouse.coldrooomtemperatures_archive` | `postgres/Warehouse/Tables/ColdRoomTemperatures_Archive.sql` |
