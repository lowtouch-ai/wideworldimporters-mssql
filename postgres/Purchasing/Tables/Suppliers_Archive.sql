CREATE SCHEMA IF NOT EXISTS purchasing;

CREATE TABLE purchasing.suppliers_archive (
    SupplierID               INTEGER        NOT NULL,
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
    DeliveryLocation         geography      NULL,
    PostalAddressLine1       VARCHAR(60)    NOT NULL,
    PostalAddressLine2       VARCHAR(60)    NULL,
    PostalPostalCode         VARCHAR(10)    NOT NULL,
    LastEditedBy             INTEGER        NOT NULL,
    ValidFrom                TIMESTAMP(6)   NOT NULL,
    ValidTo                  TIMESTAMP(6)   NOT NULL
);

CREATE INDEX ix_Suppliers_Archive ON purchasing.suppliers_archive (ValidTo ASC, ValidFrom ASC);
