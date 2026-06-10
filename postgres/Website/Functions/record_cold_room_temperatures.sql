-- Converted from: wwi-ssdt/wwi-ssdt/Website/Stored Procedures/RecordColdRoomTemperatures.sql
CREATE SCHEMA IF NOT EXISTS website;

-- NOTE: Original SP used WITH NATIVE_COMPILATION (In-Memory OLTP), SCHEMABINDING, and
-- BEGIN ATOMIC WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'English').
-- These are MSSQL In-Memory OLTP features with no PostgreSQL equivalent.
-- Converted to a standard PL/pgSQL function with equivalent UPSERT logic.

-- NOTE: @SensorReadings Website.SensorDataList READONLY TVP replaced with jsonb.
-- Callers must pass a JSON array with fields: SensorDataListID, ColdRoomSensorNumber, RecordedWhen, Temperature

CREATE OR REPLACE FUNCTION website.record_cold_room_temperatures(
    p_SensorReadings jsonb
) RETURNS void AS $$
DECLARE
    _rec record;
BEGIN
    -- Iterate over sensor readings and UPSERT
    FOR _rec IN
        SELECT
            (elem->>'ColdRoomSensorNumber')::integer AS ColdRoomSensorNumber,
            (elem->>'RecordedWhen')::timestamp(6) AS RecordedWhen,
            (elem->>'Temperature')::numeric(18,2) AS Temperature
        FROM jsonb_array_elements(p_SensorReadings) AS elem
        ORDER BY (elem->>'SensorDataListID')::integer
    LOOP
        UPDATE warehouse.coldroomtemperatures
        SET RecordedWhen = _rec.RecordedWhen,
            Temperature = _rec.Temperature
        WHERE ColdRoomSensorNumber = _rec.ColdRoomSensorNumber;

        IF NOT FOUND THEN
            INSERT INTO warehouse.coldroomtemperatures
                (ColdRoomSensorNumber, RecordedWhen, Temperature)
            VALUES (_rec.ColdRoomSensorNumber, _rec.RecordedWhen, _rec.Temperature);
        END IF;
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Unable to apply the sensor data' USING ERRCODE = 'P0001';
END;
$$ LANGUAGE plpgsql;
