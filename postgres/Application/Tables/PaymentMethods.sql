CREATE SCHEMA IF NOT EXISTS application;
CREATE SCHEMA IF NOT EXISTS sequences;

CREATE SEQUENCE IF NOT EXISTS sequences.payment_method_id_seq START 1 INCREMENT 1;

CREATE TABLE application.paymentmethods (
    PaymentMethodID   INTEGER      DEFAULT nextval('sequences.payment_method_id_seq') NOT NULL,
    PaymentMethodName VARCHAR(50)  NOT NULL,
    LastEditedBy      INTEGER      NOT NULL,
    ValidFrom         TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ValidTo           TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Application_PaymentMethods PRIMARY KEY (PaymentMethodID),
    CONSTRAINT FK_Application_PaymentMethods_Application_People FOREIGN KEY (LastEditedBy) REFERENCES application.people (PersonID),
    CONSTRAINT UQ_Application_PaymentMethods_PaymentMethodName UNIQUE (PaymentMethodName)
);

COMMENT ON TABLE application.paymentmethods IS 'Ways that payments can be made (ie: cash, check, EFT, etc.';
COMMENT ON COLUMN application.paymentmethods.PaymentMethodID IS 'Numeric ID used for reference to a payment type within the database';
COMMENT ON COLUMN application.paymentmethods.PaymentMethodName IS 'Full name of ways that customers can make payments or that suppliers can be paid';
