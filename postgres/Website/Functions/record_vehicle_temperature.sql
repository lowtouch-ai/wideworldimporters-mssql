-- Converted from: wwi-ssdt/wwi-ssdt/Website/Stored Procedures/RecordVehicleTemperature.sql
CREATE SCHEMA IF NOT EXISTS website;

CREATE OR REPLACE FUNCTION website.record_vehicle_temperature(
    p_FullSensorDataArray varchar(1000)
) RETURNS void AS $$
DECLARE
    _rowcount integer;
BEGIN
    -- Validate JSON input
    -- MSSQL: ISJSON(@FullSensorDataArray) = 0
    -- PostgreSQL: attempt cast to jsonb; catch exception
    BEGIN
        PERFORM p_FullSensorDataArray::jsonb;
    EXCEPTION
        WHEN invalid_text_representation OR others THEN
            RAISE NOTICE 'JSON sensor data is invalid.';
            RAISE EXCEPTION 'FullSensorDataArray must be valid JSON data' USING ERRCODE = 'P0001';
    END;

    -- MSSQL: OPENJSON(@FullSensorDataArray, N'$.Recordings') WITH (...)
    -- PostgreSQL: jsonb_to_recordset(p_FullSensorDataArray::jsonb -> 'Recordings')
    INSERT INTO warehouse.vehicletemperatures
        (VehicleRegistration, ChillerSensorNumber, RecordedWhen, Temperature, FullSensorData, IsCompressed, CompressedSensorData)
    SELECT
        (elem->'properties'->>'rego')::varchar(40),
        (elem->'properties'->>'sensor')::integer,
        (elem->'properties'->>'when')::timestamp(6),
        (elem->'properties'->>'temp')::numeric(18,2),
        elem::text,
        false,
        NULL
    FROM jsonb_array_elements(p_FullSensorDataArray::jsonb -> 'Recordings') AS elem;

    GET DIAGNOSTICS _rowcount = ROW_COUNT;

    IF _rowcount = 0 THEN
        RAISE NOTICE 'Warning: No valid sensor data found';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Valid JSON was supplied but does not match the temperature recordings array structure'
            USING ERRCODE = 'P0001';
END;
$$ LANGUAGE plpgsql;
