CREATE SCHEMA IF NOT EXISTS application;

CREATE TABLE application.stateprovinces_archive (
    StateProvinceID          INTEGER      NOT NULL,
    StateProvinceCode        VARCHAR(5)   NOT NULL,
    StateProvinceName        VARCHAR(50)  NOT NULL,
    CountryID                INTEGER      NOT NULL,
    SalesTerritory           VARCHAR(50)  NOT NULL,
    Border                   geography    NULL,
    LatestRecordedPopulation BIGINT       NULL,
    LastEditedBy             INTEGER      NOT NULL,
    ValidFrom                TIMESTAMP(6) NOT NULL,
    ValidTo                  TIMESTAMP(6) NOT NULL
);

CREATE INDEX ix_StateProvinces_Archive
    ON application.stateprovinces_archive (ValidTo ASC, ValidFrom ASC);
