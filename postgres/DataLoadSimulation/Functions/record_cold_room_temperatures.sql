-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/RecordColdRoomTemperatures.sql
-- Note: WITH (SNAPSHOT) hints removed; DELETE...OUTPUT INTO converted to CTE with RETURNING.
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.record_cold_room_temperatures(
    p_average_seconds_between_readings integer,
    p_number_of_sensors                integer,
    p_current_date_time                timestamp,
    p_end_of_time                      timestamp,
    p_is_silent_mode                   boolean
) RETURNS void AS $$
DECLARE
    v_time_counter          timestamp;
    v_sensor_counter        integer;
    v_time_to_finish        timestamp;
    v_temperature           numeric(10,2);
    v_archive_end_time      timestamp;
BEGIN
    v_time_counter   := CAST(p_current_date_time AS date);
    v_time_to_finish := CAST(p_current_date_time AS date)::timestamp + interval '1 day' - interval '30 seconds';

    -- clean up any artifacts from earlier runs
    DELETE FROM dataloadsimulation.coldrooomtemperatures_temp;

    IF v_time_counter < v_time_to_finish THEN
        -- seed temp table with current status of sensors, clearing the live table
        WITH deleted_rows AS (
            DELETE FROM warehouse.coldrooomtemperatures
            RETURNING "ColdRoomTemperatureID", "ColdRoomSensorNumber", "RecordedWhen", "Temperature", "ValidFrom"
        )
        INSERT INTO dataloadsimulation.coldrooomtemperatures_temp
            ("ColdRoomTemperatureID", "ColdRoomSensorNumber", "RecordedWhen", "Temperature", "ValidFrom", "ValidTo")
        SELECT dr."ColdRoomTemperatureID", dr."ColdRoomSensorNumber", dr."RecordedWhen",
               dr."Temperature", dr."ValidFrom", v_time_counter
        FROM deleted_rows AS dr;

        v_archive_end_time := v_time_to_finish - p_average_seconds_between_readings * interval '1 second';

        PERFORM dataloadsimulation.populate_cold_room_temperatures_temp(
            p_average_seconds_between_readings, p_number_of_sensors,
            v_time_counter, v_archive_end_time
        );

        -- move daily data into archive table
        WITH deleted_temp AS (
            DELETE FROM dataloadsimulation.coldrooomtemperatures_temp
            RETURNING "ColdRoomTemperatureID", "ColdRoomSensorNumber", "RecordedWhen",
                      "Temperature", "ValidFrom", "ValidTo"
        )
        INSERT INTO warehouse.coldrooomtemperatures_archive
            ("ColdRoomTemperatureID", "ColdRoomSensorNumber", "RecordedWhen", "Temperature", "ValidFrom", "ValidTo")
        SELECT "ColdRoomTemperatureID", "ColdRoomSensorNumber", "RecordedWhen",
               "Temperature", "ValidFrom", "ValidTo"
        FROM deleted_temp;

        -- add last daily reading to current live table
        v_sensor_counter := 0;
        WHILE v_sensor_counter < p_number_of_sensors LOOP
            v_temperature := 3 + random() * 2;

            INSERT INTO warehouse.coldrooomtemperatures
                ("ColdRoomSensorNumber", "RecordedWhen", "Temperature", "ValidFrom", "ValidTo")
            VALUES
                (v_sensor_counter + 1, v_archive_end_time, v_temperature, v_archive_end_time, p_end_of_time);

            v_sensor_counter := v_sensor_counter + 1;
        END LOOP;
    END IF;
END;
$$ LANGUAGE plpgsql;
