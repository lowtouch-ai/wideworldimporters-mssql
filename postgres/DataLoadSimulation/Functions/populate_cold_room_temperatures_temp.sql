-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/PopulateColdRoomTemperatures_temp.sql
-- Note: NATIVE_COMPILATION and BEGIN ATOMIC WITH SNAPSHOT converted to standard PL/pgSQL
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.populate_cold_room_temperatures_temp(
    p_average_seconds_between_readings integer,
    p_number_of_sensors                integer,
    p_time_counter                     timestamp,
    p_end_time                         timestamp
) RETURNS void AS $$
DECLARE
    v_valid_to               timestamp;
    v_delay_in_seconds       integer;
    v_sensor_counter         integer;
    v_temperature            numeric(10,2);
    v_cold_room_temperature_id bigint;
    v_time_counter           timestamp;
BEGIN
    v_time_counter := p_time_counter;

    SELECT COALESCE(MAX("ColdRoomTemperatureID"), 0) + 1
    INTO v_cold_room_temperature_id
    FROM dataloadsimulation.coldrooomtemperatures_temp;

    WHILE v_time_counter < p_end_time LOOP
        v_sensor_counter   := 0;
        v_delay_in_seconds := ceil(random() * p_average_seconds_between_readings)::integer;
        v_valid_to         := v_time_counter + v_delay_in_seconds * interval '1 second';

        WHILE v_sensor_counter < p_number_of_sensors LOOP
            v_temperature := 3 + random() * 2;

            INSERT INTO dataloadsimulation.coldrooomtemperatures_temp
                ("ColdRoomTemperatureID", "ColdRoomSensorNumber", "RecordedWhen", "Temperature", "ValidFrom", "ValidTo")
            VALUES
                (v_cold_room_temperature_id, v_sensor_counter + 1, v_time_counter, v_temperature, v_time_counter, v_valid_to);

            v_sensor_counter           := v_sensor_counter + 1;
            v_cold_room_temperature_id := v_cold_room_temperature_id + 1;
        END LOOP;

        v_time_counter := v_valid_to;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
