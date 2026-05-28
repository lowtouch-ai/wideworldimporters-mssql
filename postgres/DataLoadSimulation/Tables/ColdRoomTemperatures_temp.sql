CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

-- MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_ONLY stripped: no PostgreSQL equivalent
-- HASH index on ColdRoomSensorNumber omitted: no PostgreSQL equivalent

CREATE TABLE dataloadsimulation.coldroomtemperatures_temp
(
    ColdRoomTemperatureID BIGINT           NOT NULL,
    ColdRoomSensorNumber  INTEGER          NOT NULL,
    RecordedWhen          TIMESTAMP(6)     NOT NULL,
    Temperature           NUMERIC(10, 2)   NOT NULL,
    ValidFrom             TIMESTAMP(6)     NOT NULL,
    ValidTo               TIMESTAMP(6)     NOT NULL
);

CREATE INDEX IX_DataSimulation_ColdRoomTemperatures_ColdRoomSensorNumber
    ON dataloadsimulation.coldroomtemperatures_temp (ColdRoomSensorNumber);
