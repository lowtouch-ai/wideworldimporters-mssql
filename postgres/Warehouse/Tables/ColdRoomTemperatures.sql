CREATE SCHEMA IF NOT EXISTS warehouse;

-- MEMORY_OPTIMIZED = ON stripped: no PostgreSQL equivalent
-- SYSTEM_VERSIONING = ON stripped: temporal versioning handled separately if needed
-- PERIOD FOR SYSTEM_TIME clause removed
-- GENERATED ALWAYS AS ROW START/END converted to plain TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP

CREATE TABLE warehouse.coldroomtemperatures
(
    ColdRoomTemperatureID BIGINT         GENERATED ALWAYS AS IDENTITY NOT NULL,
    ColdRoomSensorNumber  INTEGER        NOT NULL,
    RecordedWhen          TIMESTAMP(6)   NOT NULL,
    Temperature           NUMERIC(10, 2) NOT NULL,
    ValidFrom             TIMESTAMP(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ValidTo               TIMESTAMP(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Warehouse_ColdRoomTemperatures PRIMARY KEY (ColdRoomTemperatureID)
);

CREATE INDEX IX_Warehouse_ColdRoomTemperatures_ColdRoomSensorNumber
    ON warehouse.coldroomtemperatures (ColdRoomSensorNumber);
