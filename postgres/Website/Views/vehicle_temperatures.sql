CREATE SCHEMA IF NOT EXISTS website;

CREATE OR REPLACE VIEW website.vehicle_temperatures AS
SELECT
    vt.VehicleTemperatureID,
    vt.VehicleRegistration,
    vt.ChillerSensorNumber,
    vt.RecordedWhen,
    vt.Temperature,
    CASE WHEN vt.IsCompressed = TRUE
         -- TODO: DECOMPRESS() has no direct PostgreSQL equivalent; implement a custom GZIP decompression
         -- function or use pg_extension (e.g. pgcrypto or a custom C extension) before enabling this path
         THEN NULL
         ELSE vt.FullSensorData
    END AS FullSensorData
FROM warehouse.vehicletemperatures AS vt;
