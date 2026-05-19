-- Converted from: wwi-ssdt/wwi-ssdt/Website/Stored Procedures/RecordVehicleTemperature.sql
CREATE SCHEMA IF NOT EXISTS website;

CREATE OR REPLACE FUNCTION website.record_vehicle_temperature(
    p_full_sensor_data_array text
) RETURNS void AS $$
DECLARE
    v_sensor_json jsonb;
    v_rowcount    integer;
BEGIN
    -- ISJSON(@FullSensorDataArray) = 0 → attempt cast; raise descriptive error on failure
    BEGIN
        v_sensor_json := p_full_sensor_data_array::jsonb;
    EXCEPTION WHEN invalid_text_representation THEN
        RAISE NOTICE 'JSON sensor data is invalid. An example of what is required is as follows:

{"Recordings":
    [
        {"type":"Feature", "geometry": {"type":"Point", "coordinates":[-89.7600464,50.4742420] }, "properties":{"rego":"WWI-321-A","sensor":1,"when":"2016-01-01T07:00:00","temp":3.96}},
        {"type":"Feature", "geometry": {"type":"Point", "coordinates":[-89.7600464,50.4742420] }, "properties":{"rego":"WWI-321-A","sensor":2,"when":"2016-01-01T07:00:00","temp":3.98}}
    ]
}';
        RAISE EXCEPTION 'FullSensorDataArray must be valid JSON data';
    END;

    -- OPENJSON(@FullSensorDataArray, N'$.Recordings') WITH (nested paths)
    -- → jsonb_array_elements on the Recordings array, extracting nested $.properties.* fields
    INSERT INTO warehouse.vehicletemperatures
        (vehicleregistration, chillersensornumber, recordedwhen, temperature,
         fullsensordata, iscompressed, compressedsensordata)
    SELECT
        elem->'properties'->>'rego'              AS vehicleregistration,
        (elem->'properties'->>'sensor')::integer AS chillersensornumber,
        (elem->'properties'->>'when')::timestamp AS recordedwhen,
        (elem->'properties'->>'temp')::numeric   AS temperature,
        elem::text                               AS fullsensordata,
        false,
        NULL
    FROM jsonb_array_elements(v_sensor_json->'Recordings') AS elem;

    GET DIAGNOSTICS v_rowcount = ROW_COUNT;
    IF v_rowcount = 0 THEN
        RAISE NOTICE 'Warning: No valid sensor data found';
    END IF;

EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Valid JSON was supplied but does not match the temperature recordings array structure';
    RAISE EXCEPTION 'Valid JSON was supplied but does not match the temperature recordings array structure';
END;
$$ LANGUAGE plpgsql;
