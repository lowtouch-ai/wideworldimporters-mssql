-- Converted from: wwi-ssdt/wwi-ssdt/Website/Views/VehicleTemperatures.sql
CREATE SCHEMA IF NOT EXISTS website;

CREATE OR REPLACE VIEW website.vehicle_temperatures AS
SELECT vt.VehicleTemperatureID,
       vt.VehicleRegistration,
       vt.ChillerSensorNumber,
       vt.RecordedWhen,
       vt.Temperature,
       CASE WHEN vt.IsCompressed
            -- TODO: DECOMPRESS() has no direct PostgreSQL equivalent.
            -- In PostgreSQL, compressed data stored as bytea can be decompressed with
            -- convert_from(decompress_bytea(vt.CompressedSensorData), 'UTF8') if using a custom extension,
            -- or store uncompressed. For now, returning NULL for compressed data.
            THEN NULL::text
            ELSE vt.FullSensorData
       END AS FullSensorData
FROM warehouse.vehicletemperatures AS vt;
