# Conversion summary: Website.SensorDataList

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Website/User Defined Types/SensorDataList.sql`
- **Output:** `postgres/Website/Types/sensor_data_list.sql`

## Type mapping
- **MSSQL:** `CREATE TYPE [Website].[SensorDataList] AS TABLE` (memory-optimized)
- **PostgreSQL:** `CREATE TYPE website.sensor_data_list AS` (composite type)

## Conversions applied
- `MEMORY_OPTIMIZED = ON` → removed (no PostgreSQL equivalent)
- `PRIMARY KEY NONCLUSTERED ([SensorDataListID] ASC)` → removed (composite types have no constraints)
- `IDENTITY (1, 1)` on `SensorDataListID` → removed; callers must supply this value or generate via a sequence
- `INT` → `integer`
- `DATETIME2(7)` → `timestamp(6)`
- `DECIMAL(18, 2)` → `numeric(18, 2)`

## Calling convention change

**MSSQL (TVP):**
```sql
DECLARE @data Website.SensorDataList;
INSERT INTO @data (ColdRoomSensorNumber, RecordedWhen, Temperature) VALUES (1, SYSDATETIME(), 3.5);
EXEC Website.RecordSensorData @SensorData = @data;
```

**PostgreSQL (composite type array):**
```sql
SELECT website.record_sensor_data(
    p_sensor_data := ARRAY[ROW(1, 1, NOW(), 3.5)::website.sensor_data_list]
);
```

**PostgreSQL (jsonb — mssql-to-pgfunc default):**
```sql
SELECT website.record_sensor_data(
    p_sensor_data := '[{"SensorDataListID":1,"ColdRoomSensorNumber":1,"RecordedWhen":"2016-01-01T00:00:00","Temperature":3.5}]'::jsonb
);
```

## TODOs
- `IDENTITY(1,1)` on `SensorDataListID` removed — the consuming function must either accept `SensorDataListID` from the caller or ignore it and generate IDs internally via a sequence.
- `PRIMARY KEY NONCLUSTERED ([SensorDataListID] ASC)` removed — no uniqueness enforcement on the composite type.
