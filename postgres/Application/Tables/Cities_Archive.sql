CREATE SCHEMA IF NOT EXISTS application;

CREATE TABLE application.cities_archive (
    CityID                   INTEGER      NOT NULL,
    CityName                 VARCHAR(50)  NOT NULL,
    StateProvinceID          INTEGER      NOT NULL,
    Location                 TEXT          NULL,
    LatestRecordedPopulation BIGINT       NULL,
    LastEditedBy             INTEGER      NOT NULL,
    ValidFrom                TIMESTAMP(6) NOT NULL,
    ValidTo                  TIMESTAMP(6) NOT NULL
);

CREATE INDEX ix_Cities_Archive
    ON application.cities_archive (ValidTo ASC, ValidFrom ASC);
