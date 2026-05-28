CREATE SCHEMA IF NOT EXISTS dataloadSimulation;

-- Note: original table used MEMORY_OPTIMIZED=ON with a NONCLUSTERED HASH index.
-- Converted to a regular heap table with a standard index; memory-optimized and hash index options
-- have no direct PostgreSQL equivalent.

CREATE TABLE dataloadSimulation.coldroomtemperatures_temp (
    ColdRoomTemperatureID BIGINT          NOT NULL,
    ColdRoomSensorNumber  INTEGER         NOT NULL,
    RecordedWhen          TIMESTAMP(6)    NOT NULL,
    Temperature           NUMERIC(10, 2)  NOT NULL,
    ValidFrom             TIMESTAMP(6)    NOT NULL,
    ValidTo               TIMESTAMP(6)    NOT NULL
);

CREATE INDEX IX_DataSimulation_ColdRoomTemperatures_ColdRoomSensorNumber
    ON dataloadSimulation.coldroomtemperatures_temp (ColdRoomSensorNumber);
