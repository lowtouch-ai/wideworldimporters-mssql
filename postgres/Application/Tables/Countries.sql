CREATE SCHEMA IF NOT EXISTS application;
CREATE SCHEMA IF NOT EXISTS sequences;

CREATE SEQUENCE IF NOT EXISTS sequences.country_id_seq START 1 INCREMENT 1;

CREATE TABLE application.countries (
    CountryID                INTEGER       DEFAULT nextval('sequences.country_id_seq') NOT NULL,
    CountryName              VARCHAR(60)   NOT NULL,
    FormalName               VARCHAR(60)   NOT NULL,
    IsoAlpha3Code            VARCHAR(3)    NULL,
    IsoNumericCode           INTEGER       NULL,
    CountryType              VARCHAR(20)   NULL,
    LatestRecordedPopulation BIGINT        NULL,
    Continent                VARCHAR(30)   NOT NULL,
    Region                   VARCHAR(30)   NOT NULL,
    Subregion                VARCHAR(30)   NOT NULL,
    Border                   TEXT          NULL,
    LastEditedBy             INTEGER       NOT NULL,
    ValidFrom                TIMESTAMP(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ValidTo                  TIMESTAMP(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Application_Countries PRIMARY KEY (CountryID),
    CONSTRAINT FK_Application_Countries_Application_People FOREIGN KEY (LastEditedBy) REFERENCES application.people (PersonID),
    CONSTRAINT UQ_Application_Countries_CountryName UNIQUE (CountryName),
    CONSTRAINT UQ_Application_Countries_FormalName UNIQUE (FormalName)
);

COMMENT ON TABLE application.countries IS 'Countries that contain the states or provinces (including geographic boundaries)';
COMMENT ON COLUMN application.countries.CountryID IS 'Numeric ID used for reference to a country within the database';
COMMENT ON COLUMN application.countries.CountryName IS 'Name of the country';
COMMENT ON COLUMN application.countries.FormalName IS 'Full formal name of the country as agreed by United Nations';
COMMENT ON COLUMN application.countries.IsoAlpha3Code IS '3 letter alphabetic code assigned to the country by ISO';
COMMENT ON COLUMN application.countries.IsoNumericCode IS 'Numeric code assigned to the country by ISO';
COMMENT ON COLUMN application.countries.CountryType IS 'Type of country or administrative region';
COMMENT ON COLUMN application.countries.LatestRecordedPopulation IS 'Latest available population for the country';
COMMENT ON COLUMN application.countries.Continent IS 'Name of the continent';
COMMENT ON COLUMN application.countries.Region IS 'Name of the region';
COMMENT ON COLUMN application.countries.Subregion IS 'Name of the subregion';
COMMENT ON COLUMN application.countries.Border IS 'Geographic border of the country as described by the United Nations';
