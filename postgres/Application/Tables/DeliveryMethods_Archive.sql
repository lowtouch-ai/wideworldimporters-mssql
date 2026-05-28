CREATE SCHEMA IF NOT EXISTS application;

CREATE TABLE application.delivery_methods_archive (
    DeliveryMethodID   INTEGER       NOT NULL,
    DeliveryMethodName VARCHAR(50)   NOT NULL,
    LastEditedBy       INTEGER       NOT NULL,
    ValidFrom          TIMESTAMP(6)  NOT NULL,
    ValidTo            TIMESTAMP(6)  NOT NULL
);

CREATE INDEX ix_DeliveryMethods_Archive ON application.delivery_methods_archive (ValidTo ASC, ValidFrom ASC);
