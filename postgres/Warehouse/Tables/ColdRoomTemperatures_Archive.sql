CREATE SCHEMA IF NOT EXISTS warehouse;

CREATE TABLE warehouse.coldroomtemperatures_archive
(
    ColdRoomTemperatureID BIGINT         NOT NULL,
    ColdRoomSensorNumber  INTEGER        NOT NULL,
    RecordedWhen          TIMESTAMP(6)   NOT NULL,
    Temperature           NUMERIC(10, 2) NOT NULL,
    ValidFrom             TIMESTAMP(6)   NOT NULL,
    ValidTo               TIMESTAMP(6)   NOT NULL
);

-- DATA_COMPRESSION = PAGE stripped: no PostgreSQL equivalent
CREATE INDEX ix_ColdRoomTemperatures_Archive
    ON warehouse.coldroomtemperatures_archive (ValidTo ASC, ValidFrom ASC);
