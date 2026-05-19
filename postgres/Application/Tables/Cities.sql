CREATE SCHEMA IF NOT EXISTS application;
CREATE SCHEMA IF NOT EXISTS sequences;

CREATE SEQUENCE IF NOT EXISTS sequences.city_id_seq START 1 INCREMENT 1;

CREATE TABLE application.cities (
    CityID                   INTEGER       DEFAULT nextval('sequences.city_id_seq') NOT NULL,
    CityName                 VARCHAR(50)   NOT NULL,
    StateProvinceID          INTEGER       NOT NULL,
    Location                 geography     NULL,
    LatestRecordedPopulation BIGINT        NULL,
    LastEditedBy             INTEGER       NOT NULL,
    ValidFrom                TIMESTAMP(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ValidTo                  TIMESTAMP(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Application_Cities PRIMARY KEY (CityID),
    CONSTRAINT FK_Application_Cities_Application_People FOREIGN KEY (LastEditedBy) REFERENCES application.people (PersonID),
    CONSTRAINT FK_Application_Cities_StateProvinceID_Application_StateProvinces FOREIGN KEY (StateProvinceID) REFERENCES application.stateprovinces (StateProvinceID)
);

CREATE INDEX FK_Application_Cities_StateProvinceID
    ON application.cities (StateProvinceID ASC);

-- 1 index-level extended property omitted (auto-created FK support index comment)
COMMENT ON TABLE application.cities IS 'Cities that are part of any address (including geographic location)';
COMMENT ON COLUMN application.cities.CityID IS 'Numeric ID used for reference to a city within the database';
COMMENT ON COLUMN application.cities.CityName IS 'Formal name of the city';
COMMENT ON COLUMN application.cities.StateProvinceID IS 'State or province for this city';
COMMENT ON COLUMN application.cities.Location IS 'Geographic location of the city';
COMMENT ON COLUMN application.cities.LatestRecordedPopulation IS 'Latest available population for the City';
