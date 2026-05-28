# record_cold_room_temperatures

Converted from: `wwi-ssdt/wwi-ssdt/Website/Stored Procedures/RecordColdRoomTemperatures.sql`

## Summary

Upserts cold room temperature sensor readings — updates an existing record for a sensor number or inserts a new one if none exists.

## Conversion notes

- `WITH NATIVE_COMPILATION, SCHEMABINDING` — MSSQL In-Memory OLTP features, removed. No PostgreSQL equivalent.
- `BEGIN ATOMIC WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'English')` — removed; use PostgreSQL transaction isolation settings at the session/transaction level if needed.
- `@SensorReadings Website.SensorDataList READONLY` TVP → `p_SensorReadings jsonb`
- MSSQL WHILE loop over counter → PostgreSQL `FOR _rec IN SELECT ... FROM jsonb_array_elements(...)` loop
- `@@ROWCOUNT = 0` check after UPDATE → `IF NOT FOUND THEN`
- `THROW 51000, ...` → `RAISE EXCEPTION ... USING ERRCODE = 'P0001'`
- `BEGIN TRY/CATCH` → `BEGIN ... EXCEPTION WHEN OTHERS THEN ...`

## TODOs

- Callers must serialize `SensorDataList` TVP as JSONB. Expected format:
  ```json
  [{"SensorDataListID": 1, "ColdRoomSensorNumber": 3, "RecordedWhen": "2016-01-01T07:00:00", "Temperature": 3.96}, ...]
  ```
- For high-throughput upserts, consider `INSERT ... ON CONFLICT DO UPDATE` (single-statement UPSERT) instead of the loop.

## Dependencies

| Object | Status |
|---|---|
| `warehouse.coldroomtemperatures` | check postgres/Warehouse/Tables/ColdRoomTemperatures.sql |
