CREATE SCHEMA IF NOT EXISTS application;

CREATE TABLE application.countries_archive (
    CountryID                INTEGER      NOT NULL,
    CountryName              VARCHAR(60)  NOT NULL,
    FormalName               VARCHAR(60)  NOT NULL,
    IsoAlpha3Code            VARCHAR(3)   NULL,
    IsoNumericCode           INTEGER      NULL,
    CountryType              VARCHAR(20)  NULL,
    LatestRecordedPopulation BIGINT       NULL,
    Continent                VARCHAR(30)  NOT NULL,
    Region                   VARCHAR(30)  NOT NULL,
    Subregion                VARCHAR(30)  NOT NULL,
    Border                   TEXT          NULL,
    LastEditedBy             INTEGER      NOT NULL,
    ValidFrom                TIMESTAMP(6) NOT NULL,
    ValidTo                  TIMESTAMP(6) NOT NULL
);

CREATE INDEX ix_Countries_Archive
    ON application.countries_archive (ValidTo ASC, ValidFrom ASC);
