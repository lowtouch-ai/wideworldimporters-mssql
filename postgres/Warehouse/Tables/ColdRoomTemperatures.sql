CREATE SCHEMA IF NOT EXISTS warehouse;

CREATE TABLE warehouse.coldroomtemperatures (
    ColdRoomTemperatureID BIGINT          GENERATED ALWAYS AS IDENTITY NOT NULL,
    ColdRoomSensorNumber  INTEGER         NOT NULL,
    RecordedWhen          TIMESTAMP(6)    NOT NULL,
    Temperature           NUMERIC(10, 2)  NOT NULL,
    ValidFrom             TIMESTAMP(6)    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ValidTo               TIMESTAMP(6)    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Warehouse_ColdRoomTemperatures PRIMARY KEY (ColdRoomTemperatureID)
);

CREATE INDEX IX_Warehouse_ColdRoomTemperatures_ColdRoomSensorNumber ON warehouse.coldroomtemperatures (ColdRoomSensorNumber);
