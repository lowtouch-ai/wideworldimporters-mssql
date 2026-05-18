CREATE SCHEMA IF NOT EXISTS sales;

CREATE SEQUENCE IF NOT EXISTS sequences.customer_id_seq START 1 INCREMENT 1;

CREATE TABLE sales.customers (
    CustomerID                 INTEGER          DEFAULT nextval('sequences.customer_id_seq') NOT NULL,
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
    ValidFrom                  TIMESTAMP(6)     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ValidTo                    TIMESTAMP(6)     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Sales_Customers PRIMARY KEY (CustomerID),
    CONSTRAINT FK_Sales_Customers_AlternateContactPersonID_Application_People FOREIGN KEY (AlternateContactPersonID) REFERENCES application.people (PersonID),
    CONSTRAINT FK_Sales_Customers_Application_People FOREIGN KEY (LastEditedBy) REFERENCES application.people (PersonID),
    CONSTRAINT FK_Sales_Customers_BillToCustomerID_Sales_Customers FOREIGN KEY (BillToCustomerID) REFERENCES sales.customers (CustomerID),
    CONSTRAINT FK_Sales_Customers_BuyingGroupID_Sales_BuyingGroups FOREIGN KEY (BuyingGroupID) REFERENCES sales.buyinggroups (BuyingGroupID),
    CONSTRAINT FK_Sales_Customers_CustomerCategoryID_Sales_CustomerCategories FOREIGN KEY (CustomerCategoryID) REFERENCES sales.customercategories (CustomerCategoryID),
    CONSTRAINT FK_Sales_Customers_DeliveryCityID_Application_Cities FOREIGN KEY (DeliveryCityID) REFERENCES application.cities (CityID),
    CONSTRAINT FK_Sales_Customers_DeliveryMethodID_Application_DeliveryMethods FOREIGN KEY (DeliveryMethodID) REFERENCES application.deliverymethods (DeliveryMethodID),
    CONSTRAINT FK_Sales_Customers_PostalCityID_Application_Cities FOREIGN KEY (PostalCityID) REFERENCES application.cities (CityID),
    CONSTRAINT FK_Sales_Customers_PrimaryContactPersonID_Application_People FOREIGN KEY (PrimaryContactPersonID) REFERENCES application.people (PersonID),
    CONSTRAINT UQ_Sales_Customers_CustomerName UNIQUE (CustomerName)
);

CREATE INDEX FK_Sales_Customers_CustomerCategoryID ON sales.customers (CustomerCategoryID ASC);
CREATE INDEX FK_Sales_Customers_BuyingGroupID ON sales.customers (BuyingGroupID ASC);
CREATE INDEX FK_Sales_Customers_PrimaryContactPersonID ON sales.customers (PrimaryContactPersonID ASC);
CREATE INDEX FK_Sales_Customers_AlternateContactPersonID ON sales.customers (AlternateContactPersonID ASC);
CREATE INDEX FK_Sales_Customers_DeliveryMethodID ON sales.customers (DeliveryMethodID ASC);
CREATE INDEX FK_Sales_Customers_DeliveryCityID ON sales.customers (DeliveryCityID ASC);
CREATE INDEX FK_Sales_Customers_PostalCityID ON sales.customers (PostalCityID ASC);
CREATE INDEX IX_Sales_Customers_Perf_20160301_06 ON sales.customers (IsOnCreditHold ASC, CustomerID ASC, BillToCustomerID ASC) INCLUDE (PrimaryContactPersonID);

-- 8 index-level extended properties omitted (no PostgreSQL equivalent)

COMMENT ON TABLE sales.customers IS 'Main entity tables for customers (organizations or individuals)';

COMMENT ON COLUMN sales.customers.CustomerID IS 'Numeric ID used for reference to a customer within the database';
COMMENT ON COLUMN sales.customers.CustomerName IS 'Customer''s full name (usually a trading name)';
COMMENT ON COLUMN sales.customers.BillToCustomerID IS 'Customer that this is billed to (usually the same customer but can be another parent company)';
COMMENT ON COLUMN sales.customers.CustomerCategoryID IS 'Customer''s category';
COMMENT ON COLUMN sales.customers.BuyingGroupID IS 'Customer''s buying group (optional)';
COMMENT ON COLUMN sales.customers.PrimaryContactPersonID IS 'Primary contact';
COMMENT ON COLUMN sales.customers.AlternateContactPersonID IS 'Alternate contact';
COMMENT ON COLUMN sales.customers.DeliveryMethodID IS 'Standard delivery method for stock items sent to this customer';
COMMENT ON COLUMN sales.customers.DeliveryCityID IS 'ID of the delivery city for this address';
COMMENT ON COLUMN sales.customers.PostalCityID IS 'ID of the postal city for this address';
COMMENT ON COLUMN sales.customers.CreditLimit IS 'Credit limit for this customer (NULL if unlimited)';
COMMENT ON COLUMN sales.customers.AccountOpenedDate IS 'Date this customer account was opened';
COMMENT ON COLUMN sales.customers.StandardDiscountPercentage IS 'Standard discount offered to this customer';
COMMENT ON COLUMN sales.customers.IsStatementSent IS 'Is a statement sent to this customer? (Or do they just pay on each invoice?)';
COMMENT ON COLUMN sales.customers.IsOnCreditHold IS 'Is this customer on credit hold? (Prevents further deliveries to this customer)';
COMMENT ON COLUMN sales.customers.PaymentDays IS 'Number of days for payment of an invoice (ie payment terms)';
COMMENT ON COLUMN sales.customers.PhoneNumber IS 'Phone number';
COMMENT ON COLUMN sales.customers.FaxNumber IS 'Fax number';
COMMENT ON COLUMN sales.customers.DeliveryRun IS 'Normal delivery run for this customer';
COMMENT ON COLUMN sales.customers.RunPosition IS 'Normal position in the delivery run for this customer';
COMMENT ON COLUMN sales.customers.WebsiteURL IS 'URL for the website for this customer';
COMMENT ON COLUMN sales.customers.DeliveryAddressLine1 IS 'First delivery address line for the customer';
COMMENT ON COLUMN sales.customers.DeliveryAddressLine2 IS 'Second delivery address line for the customer';
COMMENT ON COLUMN sales.customers.DeliveryPostalCode IS 'Delivery postal code for the customer';
COMMENT ON COLUMN sales.customers.DeliveryLocation IS 'Geographic location for the customer''s office/warehouse';
COMMENT ON COLUMN sales.customers.PostalAddressLine1 IS 'First postal address line for the customer';
COMMENT ON COLUMN sales.customers.PostalAddressLine2 IS 'Second postal address line for the customer';
COMMENT ON COLUMN sales.customers.PostalPostalCode IS 'Postal code for the customer when sending by mail';
