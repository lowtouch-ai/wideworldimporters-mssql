CREATE SCHEMA IF NOT EXISTS application;
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE SEQUENCE IF NOT EXISTS sequences.state_province_id_seq START 54 INCREMENT 1;

CREATE TABLE application.state_provinces (
    StateProvinceID          INTEGER         DEFAULT nextval('sequences.state_province_id_seq') NOT NULL,
    StateProvinceCode        VARCHAR(5)      NOT NULL,
    StateProvinceName        VARCHAR(50)     NOT NULL,
    CountryID                INTEGER         NOT NULL,
    SalesTerritory           VARCHAR(50)     NOT NULL,
    Border                   geography       NULL,
    LatestRecordedPopulation BIGINT          NULL,
    LastEditedBy             INTEGER         NOT NULL,
    ValidFrom                TIMESTAMP(6)    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ValidTo                  TIMESTAMP(6)    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Application_StateProvinces PRIMARY KEY (StateProvinceID),
    CONSTRAINT FK_Application_StateProvinces_Application_People FOREIGN KEY (LastEditedBy) REFERENCES application.people (PersonID),
    CONSTRAINT FK_Application_StateProvinces_CountryID_Application_Countries FOREIGN KEY (CountryID) REFERENCES application.countries (CountryID),
    CONSTRAINT UQ_Application_StateProvinces_StateProvinceName UNIQUE (StateProvinceName)
);

CREATE INDEX FK_Application_StateProvinces_CountryID ON application.state_provinces (CountryID ASC);
CREATE INDEX IX_Application_StateProvinces_SalesTerritory ON application.state_provinces (SalesTerritory ASC);

-- 2 index-level extended properties omitted (index comments not supported via standard DDL)
COMMENT ON TABLE application.state_provinces IS 'States or provinces that contain cities (including geographic location)';
COMMENT ON COLUMN application.state_provinces.StateProvinceID IS 'Numeric ID used for reference to a state or province within the database';
COMMENT ON COLUMN application.state_provinces.StateProvinceCode IS 'Common code for this state or province (such as WA - Washington for the USA)';
COMMENT ON COLUMN application.state_provinces.StateProvinceName IS 'Formal name of the state or province';
COMMENT ON COLUMN application.state_provinces.CountryID IS 'Country for this StateProvince';
COMMENT ON COLUMN application.state_provinces.SalesTerritory IS 'Sales territory for this StateProvince';
COMMENT ON COLUMN application.state_provinces.Border IS 'Geographic boundary of the state or province';
COMMENT ON COLUMN application.state_provinces.LatestRecordedPopulation IS 'Latest available population for the StateProvince';
