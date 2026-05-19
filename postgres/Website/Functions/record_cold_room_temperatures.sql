-- Converted from: wwi-ssdt/wwi-ssdt/Website/Stored Procedures/RecordColdRoomTemperatures.sql
-- WITH NATIVE_COMPILATION, SCHEMABINDING (Hekaton in-memory) stripped entirely.
-- WHILE loop rewritten as FOR loop — multiple readings per sensor are processed in SensorDataListID order.
-- No unique constraint on warehouse.coldroomtemperatures.coldroomsensornumber, so ON CONFLICT cannot be used;
-- UPDATE + GET DIAGNOSTICS + INSERT preserves the original row-by-row upsert semantics.
CREATE SCHEMA IF NOT EXISTS website;

CREATE OR REPLACE FUNCTION website.record_cold_room_temperatures(
    p_sensor_readings website.sensor_data_list[]
) RETURNS void AS $$
DECLARE
    v_rowcount integer;
    rec        record;
BEGIN
    FOR rec IN
        SELECT s.coldroomsensornumber,
               s.recordedwhen,
               s.temperature
        FROM UNNEST(p_sensor_readings) AS s
        ORDER BY s.sensordatalistid
    LOOP
        UPDATE warehouse.coldroomtemperatures
        SET recordedwhen = rec.recordedwhen,
            temperature  = rec.temperature
        WHERE coldroomsensornumber = rec.coldroomsensornumber;

        GET DIAGNOSTICS v_rowcount = ROW_COUNT;
        IF v_rowcount = 0 THEN
            INSERT INTO warehouse.coldroomtemperatures
                (coldroomsensornumber, recordedwhen, temperature)
            VALUES (rec.coldroomsensornumber, rec.recordedwhen, rec.temperature);
        END IF;
    END LOOP;

EXCEPTION WHEN OTHERS THEN
    RAISE EXCEPTION 'Unable to apply the sensor data';
END;
$$ LANGUAGE plpgsql;
