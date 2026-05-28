CREATE SCHEMA IF NOT EXISTS sales;

CREATE TABLE sales.customers_archive (
    CustomerID                 INTEGER          NOT NULL,
    CustomerName               VARCHAR(100)     NOT NULL,
    BillToCustomerID           INTEGER          NOT NULL,
    CustomerCategoryID         INTEGER          NOT NULL,
    BuyingGroupID              INTEGER          NULL,
    PrimaryContactPersonID     INTEGER          NOT NULL,
    AlternateContactPersonID   INTEGER          NULL,
    DeliveryMethodID           INTEGER          NOT NULL,
    DeliveryCityID             INTEGER          NOT NULL,
    PostalCityID               INTEGER          NOT NULL,
    CreditLimit                NUMERIC(18, 2)   NULL,
    AccountOpenedDate          DATE             NOT NULL,
    StandardDiscountPercentage NUMERIC(18, 3)   NOT NULL,
    IsStatementSent            BOOLEAN          NOT NULL,
    IsOnCreditHold             BOOLEAN          NOT NULL,
    PaymentDays                INTEGER          NOT NULL,
    PhoneNumber                VARCHAR(20)      NOT NULL,
    FaxNumber                  VARCHAR(20)      NOT NULL,
    DeliveryRun                VARCHAR(5)       NULL,
    RunPosition                VARCHAR(5)       NULL,
    WebsiteURL                 VARCHAR(256)     NOT NULL,
    DeliveryAddressLine1       VARCHAR(60)      NOT NULL,
    DeliveryAddressLine2       VARCHAR(60)      NULL,
    DeliveryPostalCode         VARCHAR(10)      NOT NULL,
    DeliveryLocation           geography        NULL,
    PostalAddressLine1         VARCHAR(60)      NOT NULL,
    PostalAddressLine2         VARCHAR(60)      NULL,
    PostalPostalCode           VARCHAR(10)      NOT NULL,
    LastEditedBy               INTEGER          NOT NULL,
    ValidFrom                  TIMESTAMP(6)     NOT NULL,
    ValidTo                    TIMESTAMP(6)     NOT NULL
);

CREATE INDEX ix_Customers_Archive ON sales.customers_archive (ValidTo ASC, ValidFrom ASC);
