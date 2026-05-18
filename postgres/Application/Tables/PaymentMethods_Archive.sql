CREATE SCHEMA IF NOT EXISTS application;

CREATE TABLE application.payment_methods_archive (
    PaymentMethodID   INTEGER       NOT NULL,
    PaymentMethodName VARCHAR(50)   NOT NULL,
    LastEditedBy      INTEGER       NOT NULL,
    ValidFrom         TIMESTAMP(6)  NOT NULL,
    ValidTo           TIMESTAMP(6)  NOT NULL
);

CREATE INDEX ix_PaymentMethods_Archive ON application.payment_methods_archive (ValidTo ASC, ValidFrom ASC);
