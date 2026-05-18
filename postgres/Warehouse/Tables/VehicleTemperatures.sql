CREATE SCHEMA IF NOT EXISTS warehouse;

-- MEMORY_OPTIMIZED = ON stripped: no PostgreSQL equivalent

CREATE TABLE warehouse.vehicletemperatures
(
    VehicleTemperatureID BIGINT          GENERATED ALWAYS AS IDENTITY NOT NULL,
    VehicleRegistration  VARCHAR(20)     NOT NULL,
    ChillerSensorNumber  INTEGER         NOT NULL,
    RecordedWhen         TIMESTAMP(6)    NOT NULL,
    Temperature          NUMERIC(10, 2)  NOT NULL,
    FullSensorData       VARCHAR(1000)   NULL,
    IsCompressed         BOOLEAN         NOT NULL,
    CompressedSensorData BYTEA           NULL,
    CONSTRAINT PK_Warehouse_VehicleTemperatures PRIMARY KEY (VehicleTemperatureID)
);
