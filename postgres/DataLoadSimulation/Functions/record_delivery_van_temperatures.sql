-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/RecordDeliveryVanTemperatures.sql
-- TODO: COMPRESS() has no direct PostgreSQL equivalent; CompressedSensorData is stored as NULL.
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.record_delivery_van_temperatures(
    p_average_seconds_between_readings integer,
    p_number_of_sensors                integer,
    p_current_date_time                timestamp,
    p_starting_when                    timestamp,
    p_is_silent_mode                   boolean
) RETURNS void AS $$
DECLARE
    v_vehicle_registration  varchar(20) := 'WWI-321-A';
    v_time_counter          timestamp;
    v_sensor_counter        integer;
    v_delay_in_seconds      integer;
    v_time_to_finish        timestamp;
    v_temperature           numeric(10,2);
    v_full_sensor_data      varchar(1000);
    v_latitude              numeric(18,7);
    v_longitude             numeric(18,7);
    v_is_compressed         boolean;
BEGIN
    v_time_counter   := p_starting_when;
    v_time_to_finish := CAST(p_starting_when AS date)::timestamp + interval '16 hours';

    WHILE v_time_counter < v_time_to_finish LOOP
        v_sensor_counter := 0;

        WHILE v_sensor_counter < p_number_of_sensors LOOP
            v_temperature := 3 + random() * 2;
            v_latitude    := 37.78352 + random() * 30;
            v_longitude   := -122.4169 + random() * 40;
            v_is_compressed := v_time_counter < '2022-01-01'::timestamp;

            v_full_sensor_data :=
                '{"Recordings": '
                || '[{"type":"Feature", "geometry": {"type":"Point", "coordinates":['
                || CAST(v_longitude AS varchar) || ',' || CAST(v_latitude AS varchar)
                || '] }, "properties":{"rego":"' || v_vehicle_registration
                || '","sensor":' || CAST(v_sensor_counter + 1 AS varchar)
                || ',"when":"' || to_char(v_time_counter, 'YYYY-MM-DD"T"HH24:MI:SS')
                || '","temp":' || CAST(v_temperature AS varchar)
                || '}} ]'
                || '}';

            INSERT INTO warehouse.vehicletemperatures
                ("VehicleRegistration", "ChillerSensorNumber",
                 "RecordedWhen", "Temperature",
                 "FullSensorData", "IsCompressed", "CompressedSensorData")
            VALUES
                (v_vehicle_registration, v_sensor_counter + 1,
                 v_time_counter, v_temperature,
                 CASE WHEN NOT v_is_compressed THEN v_full_sensor_data END,
                 v_is_compressed,
                 -- TODO: COMPRESS() not available; use pg_compress extension for real compression
                 NULL);

            v_sensor_counter := v_sensor_counter + 1;
        END LOOP;

        v_delay_in_seconds := ceil(random() * p_average_seconds_between_readings)::integer;
        v_time_counter     := v_time_counter + v_delay_in_seconds * interval '1 second';
    END LOOP;
END;
$$ LANGUAGE plpgsql;
