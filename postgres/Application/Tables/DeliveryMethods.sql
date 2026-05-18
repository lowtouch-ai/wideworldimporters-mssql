CREATE SCHEMA IF NOT EXISTS application;
CREATE SEQUENCE IF NOT EXISTS sequences.delivery_method_id_seq START 11 INCREMENT 1;

CREATE TABLE application.delivery_methods (
    DeliveryMethodID   INTEGER       DEFAULT nextval('sequences.delivery_method_id_seq') NOT NULL,
    DeliveryMethodName VARCHAR(50)   NOT NULL,
    LastEditedBy       INTEGER       NOT NULL,
    ValidFrom          TIMESTAMP(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ValidTo            TIMESTAMP(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Application_DeliveryMethods PRIMARY KEY (DeliveryMethodID),
    CONSTRAINT FK_Application_DeliveryMethods_Application_People FOREIGN KEY (LastEditedBy) REFERENCES application.people (PersonID),
    CONSTRAINT UQ_Application_DeliveryMethods_DeliveryMethodName UNIQUE (DeliveryMethodName)
);

COMMENT ON TABLE application.delivery_methods IS 'Ways that stock items can be delivered (ie: truck/van, post, pickup, courier, etc.';
COMMENT ON COLUMN application.delivery_methods.DeliveryMethodID IS 'Numeric ID used for reference to a delivery method within the database';
COMMENT ON COLUMN application.delivery_methods.DeliveryMethodName IS 'Full name of methods that can be used for delivery of customer orders';
