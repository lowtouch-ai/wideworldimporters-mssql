# Conversion summary: Website.RecordColdRoomTemperatures

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Website/Stored Procedures/RecordColdRoomTemperatures.sql`
- **Pattern:** TVP-based transaction → `RETURNS void`
- **Output:** `postgres/Website/Functions/record_cold_room_temperatures.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION website.record_cold_room_temperatures(
    p_sensor_readings website.sensor_data_list[]
) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@SensorReadings Website.SensorDataList READONLY` | `p_sensor_readings website.sensor_data_list[]` | composite type array | TVP → array of composite type |

## Conversion notes
- `WITH NATIVE_COMPILATION, SCHEMABINDING` (Hekaton in-memory) stripped entirely — not applicable to standard PostgreSQL
- `BEGIN ATOMIC WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'English')` stripped
- WHILE loop (MIN/MAX SensorDataListID counter) → `FOR rec IN SELECT ... FROM UNNEST(p_sensor_readings) ORDER BY sensordatalistid`
- UPDATE + `IF @@ROWCOUNT = 0 THEN INSERT` → UPDATE + `GET DIAGNOSTICS v_rowcount = ROW_COUNT; IF v_rowcount = 0 THEN INSERT`
- `ON CONFLICT DO UPDATE` was not used because `coldroomsensornumber` has no UNIQUE constraint in the PostgreSQL DDL; the row-by-row loop preserves "last reading wins" semantics for duplicate sensor numbers
- `BEGIN TRY ... BEGIN CATCH THROW` → `EXCEPTION WHEN OTHERS THEN RAISE EXCEPTION`

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `warehouse.coldroomtemperatures` | `postgres/Warehouse/Tables/ColdRoomTemperatures.sql` |
