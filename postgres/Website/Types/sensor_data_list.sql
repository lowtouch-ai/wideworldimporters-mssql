-- Converted from: wwi-ssdt/wwi-ssdt/Website/User Defined Types/SensorDataList.sql
CREATE SCHEMA IF NOT EXISTS website;

-- Re-run: DROP TYPE IF EXISTS website.sensor_data_list; before applying if type already exists.
-- NOTE: SensorDataListID had IDENTITY(1,1) in MSSQL — callers must supply this value or use a sequence.
CREATE TYPE website.sensor_data_list AS (
    SensorDataListID     integer,
    ColdRoomSensorNumber integer,
    RecordedWhen         timestamp(6),
    Temperature          numeric(18, 2)
);
