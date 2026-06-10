CREATE SCHEMA IF NOT EXISTS purchasing;
CREATE SCHEMA IF NOT EXISTS sequences;

CREATE SEQUENCE IF NOT EXISTS sequences.supplier_id_seq START 14 INCREMENT 1;

CREATE TABLE purchasing.suppliers (
    SupplierID               INTEGER        DEFAULT nextval('sequences.supplier_id_seq') NOT NULL,
    SupplierName             VARCHAR(100)   NOT NULL,
    SupplierCategoryID       INTEGER        NOT NULL,
    PrimaryContactPersonID   INTEGER        NOT NULL,
    AlternateContactPersonID INTEGER        NOT NULL,
    DeliveryMethodID         INTEGER        NULL,
    DeliveryCityID           INTEGER        NOT NULL,
    PostalCityID             INTEGER        NOT NULL,
    SupplierReference        VARCHAR(20)    NULL,
    BankAccountName          VARCHAR(50)    NULL,
    BankAccountBranch        VARCHAR(50)    NULL,
    BankAccountCode          VARCHAR(20)    NULL,
    BankAccountNumber        VARCHAR(20)    NULL,
    BankInternationalCode    VARCHAR(20)    NULL,
    PaymentDays              INTEGER        NOT NULL,
    InternalComments         TEXT           NULL,
    PhoneNumber              VARCHAR(20)    NOT NULL,
    FaxNumber                VARCHAR(20)    NOT NULL,
    WebsiteURL               VARCHAR(256)   NOT NULL,
    DeliveryAddressLine1     VARCHAR(60)    NOT NULL,
    DeliveryAddressLine2     VARCHAR(60)    NULL,
    DeliveryPostalCode       VARCHAR(10)    NOT NULL,
    DeliveryLocation         TEXT          NULL,
    PostalAddressLine1       VARCHAR(60)    NOT NULL,
    PostalAddressLine2       VARCHAR(60)    NULL,
    PostalPostalCode         VARCHAR(10)    NOT NULL,
    LastEditedBy             INTEGER        NOT NULL,
    ValidFrom                TIMESTAMP(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ValidTo                  TIMESTAMP(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Purchasing_Suppliers PRIMARY KEY (SupplierID),
    CONSTRAINT FK_Purchasing_Suppliers_AlternateContactPersonID_Application_People FOREIGN KEY (AlternateContactPersonID) REFERENCES application.people (PersonID),
    CONSTRAINT FK_Purchasing_Suppliers_Application_People FOREIGN KEY (LastEditedBy) REFERENCES application.people (PersonID),
    CONSTRAINT FK_Purchasing_Suppliers_DeliveryCityID_Application_Cities FOREIGN KEY (DeliveryCityID) REFERENCES application.cities (CityID),
    CONSTRAINT FK_Purchasing_Suppliers_DeliveryMethodID_Application_DeliveryMethods FOREIGN KEY (DeliveryMethodID) REFERENCES application.deliverymethods (DeliveryMethodID),
    CONSTRAINT FK_Purchasing_Suppliers_PostalCityID_Application_Cities FOREIGN KEY (PostalCityID) REFERENCES application.cities (CityID),
    CONSTRAINT FK_Purchasing_Suppliers_PrimaryContactPersonID_Application_People FOREIGN KEY (PrimaryContactPersonID) REFERENCES application.people (PersonID),
    CONSTRAINT FK_Purchasing_Suppliers_SupplierCategoryID_Purchasing_SupplierCategories FOREIGN KEY (SupplierCategoryID) REFERENCES purchasing.suppliercategories (SupplierCategoryID),
    CONSTRAINT UQ_Purchasing_Suppliers_SupplierName UNIQUE (SupplierName)
);

CREATE INDEX FK_Purchasing_Suppliers_SupplierCategoryID ON purchasing.suppliers (SupplierCategoryID ASC);
CREATE INDEX FK_Purchasing_Suppliers_PrimaryContactPersonID ON purchasing.suppliers (PrimaryContactPersonID ASC);
CREATE INDEX FK_Purchasing_Suppliers_AlternateContactPersonID ON purchasing.suppliers (AlternateContactPersonID ASC);
CREATE INDEX FK_Purchasing_Suppliers_DeliveryMethodID ON purchasing.suppliers (DeliveryMethodID ASC);
CREATE INDEX FK_Purchasing_Suppliers_DeliveryCityID ON purchasing.suppliers (DeliveryCityID ASC);
CREATE INDEX FK_Purchasing_Suppliers_PostalCityID ON purchasing.suppliers (PostalCityID ASC);

COMMENT ON TABLE purchasing.suppliers IS 'Main entity table for suppliers (organizations)';
COMMENT ON COLUMN purchasing.suppliers.SupplierID IS 'Numeric ID used for reference to a supplier within the database';
COMMENT ON COLUMN purchasing.suppliers.SupplierName IS 'Supplier''s full name (usually a trading name)';
COMMENT ON COLUMN purchasing.suppliers.SupplierCategoryID IS 'Supplier''s category';
COMMENT ON COLUMN purchasing.suppliers.PrimaryContactPersonID IS 'Primary contact';
COMMENT ON COLUMN purchasing.suppliers.AlternateContactPersonID IS 'Alternate contact';
COMMENT ON COLUMN purchasing.suppliers.DeliveryMethodID IS 'Standard delivery method for stock items received from this supplier';
COMMENT ON COLUMN purchasing.suppliers.DeliveryCityID IS 'ID of the delivery city for this address';
COMMENT ON COLUMN purchasing.suppliers.PostalCityID IS 'ID of the mailing city for this address';
COMMENT ON COLUMN purchasing.suppliers.SupplierReference IS 'Supplier reference for our organization (might be our account number at the supplier)';
COMMENT ON COLUMN purchasing.suppliers.BankAccountName IS 'Supplier''s bank account name (ie name on the account)';
COMMENT ON COLUMN purchasing.suppliers.BankAccountBranch IS 'Supplier''s bank branch';
COMMENT ON COLUMN purchasing.suppliers.BankAccountCode IS 'Supplier''s bank account code (usually a numeric reference for the bank branch)';
COMMENT ON COLUMN purchasing.suppliers.BankAccountNumber IS 'Supplier''s bank account number';
COMMENT ON COLUMN purchasing.suppliers.BankInternationalCode IS 'Supplier''s bank''s international code (such as a SWIFT code)';
COMMENT ON COLUMN purchasing.suppliers.PaymentDays IS 'Number of days for payment of an invoice (ie payment terms)';
COMMENT ON COLUMN purchasing.suppliers.InternalComments IS 'Internal comments (not exposed outside organization)';
COMMENT ON COLUMN purchasing.suppliers.PhoneNumber IS 'Phone number';
COMMENT ON COLUMN purchasing.suppliers.FaxNumber IS 'Fax number';
COMMENT ON COLUMN purchasing.suppliers.WebsiteURL IS 'URL for the website for this supplier';
COMMENT ON COLUMN purchasing.suppliers.DeliveryAddressLine1 IS 'First delivery address line for the supplier';
COMMENT ON COLUMN purchasing.suppliers.DeliveryAddressLine2 IS 'Second delivery address line for the supplier';
COMMENT ON COLUMN purchasing.suppliers.DeliveryPostalCode IS 'Delivery postal code for the supplier';
COMMENT ON COLUMN purchasing.suppliers.DeliveryLocation IS 'Geographic location for the supplier''s office/warehouse';
COMMENT ON COLUMN purchasing.suppliers.PostalAddressLine1 IS 'First postal address line for the supplier';
COMMENT ON COLUMN purchasing.suppliers.PostalAddressLine2 IS 'Second postal address line for the supplier';
COMMENT ON COLUMN purchasing.suppliers.PostalPostalCode IS 'Postal code for the supplier when sending by mail';
