CREATE SCHEMA IF NOT EXISTS application;
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE SEQUENCE IF NOT EXISTS sequences.system_parameter_id_seq START 3 INCREMENT 1;

CREATE TABLE application.system_parameters (
    SystemParameterID    INTEGER         DEFAULT nextval('sequences.system_parameter_id_seq') NOT NULL,
    DeliveryAddressLine1 VARCHAR(60)     NOT NULL,
    DeliveryAddressLine2 VARCHAR(60)     NULL,
    DeliveryCityID       INTEGER         NOT NULL,
    DeliveryPostalCode   VARCHAR(10)     NOT NULL,
    DeliveryLocation     geography       NOT NULL,
    PostalAddressLine1   VARCHAR(60)     NOT NULL,
    PostalAddressLine2   VARCHAR(60)     NULL,
    PostalCityID         INTEGER         NOT NULL,
    PostalPostalCode     VARCHAR(10)     NOT NULL,
    ApplicationSettings  TEXT            NOT NULL,
    LastEditedBy         INTEGER         NOT NULL,
    LastEditedWhen       TIMESTAMP(6)    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Application_SystemParameters PRIMARY KEY (SystemParameterID),
    CONSTRAINT FK_Application_SystemParameters_Application_People FOREIGN KEY (LastEditedBy) REFERENCES application.people (PersonID),
    CONSTRAINT FK_Application_SystemParameters_DeliveryCityID_Application_Cities FOREIGN KEY (DeliveryCityID) REFERENCES application.cities (CityID),
    CONSTRAINT FK_Application_SystemParameters_PostalCityID_Application_Cities FOREIGN KEY (PostalCityID) REFERENCES application.cities (CityID)
);

CREATE INDEX FK_Application_SystemParameters_DeliveryCityID ON application.system_parameters (DeliveryCityID ASC);
CREATE INDEX FK_Application_SystemParameters_PostalCityID ON application.system_parameters (PostalCityID ASC);

-- 2 index-level extended properties omitted (index comments not supported via standard DDL)
COMMENT ON TABLE application.system_parameters IS 'Any configurable parameters for the whole system';
COMMENT ON COLUMN application.system_parameters.SystemParameterID IS 'Numeric ID used for row holding system parameters';
COMMENT ON COLUMN application.system_parameters.DeliveryAddressLine1 IS 'First address line for the company';
COMMENT ON COLUMN application.system_parameters.DeliveryAddressLine2 IS 'Second address line for the company';
COMMENT ON COLUMN application.system_parameters.DeliveryCityID IS 'ID of the city for this address';
COMMENT ON COLUMN application.system_parameters.DeliveryPostalCode IS 'Postal code for the company';
COMMENT ON COLUMN application.system_parameters.DeliveryLocation IS 'Geographic location for the company office';
COMMENT ON COLUMN application.system_parameters.PostalAddressLine1 IS 'First postal address line for the company';
COMMENT ON COLUMN application.system_parameters.PostalAddressLine2 IS 'Second postaladdress line for the company';
COMMENT ON COLUMN application.system_parameters.PostalCityID IS 'ID of the city for this postaladdress';
COMMENT ON COLUMN application.system_parameters.PostalPostalCode IS 'Postal code for the company when sending via mail';
COMMENT ON COLUMN application.system_parameters.ApplicationSettings IS 'JSON-structured application settings';
