CREATE SCHEMA IF NOT EXISTS sales;
CREATE SCHEMA IF NOT EXISTS sequences;

CREATE SEQUENCE IF NOT EXISTS sequences.invoice_id_seq START 1 INCREMENT 1;

CREATE TABLE sales.invoices (
    InvoiceID                   INTEGER      DEFAULT nextval('sequences.invoice_id_seq') NOT NULL,
    CustomerID                  INTEGER      NOT NULL,
    BillToCustomerID            INTEGER      NOT NULL,
    OrderID                     INTEGER      NULL,
    DeliveryMethodID            INTEGER      NOT NULL,
    ContactPersonID             INTEGER      NOT NULL,
    AccountsPersonID            INTEGER      NOT NULL,
    SalespersonPersonID         INTEGER      NOT NULL,
    PackedByPersonID            INTEGER      NOT NULL,
    InvoiceDate                 DATE         NOT NULL,
    CustomerPurchaseOrderNumber VARCHAR(20)  NULL,
    IsCreditNote                BOOLEAN      NOT NULL,
    CreditNoteReason            TEXT         NULL,
    Comments                    TEXT         NULL,
    DeliveryInstructions        TEXT         NULL,
    InternalComments            TEXT         NULL,
    TotalDryItems               INTEGER      NOT NULL,
    TotalChillerItems           INTEGER      NOT NULL,
    DeliveryRun                 VARCHAR(5)   NULL,
    RunPosition                 VARCHAR(5)   NULL,
    ReturnedDeliveryData        TEXT         NULL,
    ConfirmedDeliveryTime       TIMESTAMP(6) NULL, -- NOTE: was computed from ReturnedDeliveryData::json->>'DeliveredWhen'; json cast is STABLE not IMMUTABLE
    ConfirmedReceivedBy         TEXT         NULL, -- NOTE: was computed from ReturnedDeliveryData::json->>'ReceivedBy'; populate via trigger or application layer
    LastEditedBy                INTEGER      NOT NULL,
    LastEditedWhen              TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Sales_Invoices PRIMARY KEY (InvoiceID),
    CONSTRAINT FK_Sales_Invoices_AccountsPersonID_Application_People FOREIGN KEY (AccountsPersonID) REFERENCES application.people (PersonID),
    CONSTRAINT FK_Sales_Invoices_Application_People FOREIGN KEY (LastEditedBy) REFERENCES application.people (PersonID),
    CONSTRAINT FK_Sales_Invoices_BillToCustomerID_Sales_Customers FOREIGN KEY (BillToCustomerID) REFERENCES sales.customers (CustomerID),
    CONSTRAINT FK_Sales_Invoices_ContactPersonID_Application_People FOREIGN KEY (ContactPersonID) REFERENCES application.people (PersonID),
    CONSTRAINT FK_Sales_Invoices_CustomerID_Sales_Customers FOREIGN KEY (CustomerID) REFERENCES sales.customers (CustomerID),
    CONSTRAINT FK_Sales_Invoices_DeliveryMethodID_Application_DeliveryMethods FOREIGN KEY (DeliveryMethodID) REFERENCES application.deliverymethods (DeliveryMethodID),
    CONSTRAINT FK_Sales_Invoices_OrderID_Sales_Orders FOREIGN KEY (OrderID) REFERENCES sales.orders (OrderID),
    CONSTRAINT FK_Sales_Invoices_PackedByPersonID_Application_People FOREIGN KEY (PackedByPersonID) REFERENCES application.people (PersonID),
    CONSTRAINT FK_Sales_Invoices_SalespersonPersonID_Application_People FOREIGN KEY (SalespersonPersonID) REFERENCES application.people (PersonID)
);

CREATE INDEX FK_Sales_Invoices_CustomerID ON sales.invoices (CustomerID ASC);
CREATE INDEX FK_Sales_Invoices_BillToCustomerID ON sales.invoices (BillToCustomerID ASC);
CREATE INDEX FK_Sales_Invoices_OrderID ON sales.invoices (OrderID ASC);
CREATE INDEX FK_Sales_Invoices_DeliveryMethodID ON sales.invoices (DeliveryMethodID ASC);
CREATE INDEX FK_Sales_Invoices_ContactPersonID ON sales.invoices (ContactPersonID ASC);
CREATE INDEX FK_Sales_Invoices_AccountsPersonID ON sales.invoices (AccountsPersonID ASC);
CREATE INDEX FK_Sales_Invoices_SalespersonPersonID ON sales.invoices (SalespersonPersonID ASC);
CREATE INDEX FK_Sales_Invoices_PackedByPersonID ON sales.invoices (PackedByPersonID ASC);
CREATE INDEX IX_Sales_Invoices_ConfirmedDeliveryTime ON sales.invoices (ConfirmedDeliveryTime ASC) INCLUDE (ConfirmedReceivedBy);

COMMENT ON TABLE sales.invoices IS 'Details of customer invoices';
COMMENT ON COLUMN sales.invoices.InvoiceID IS 'Numeric ID used for reference to an invoice within the database';
COMMENT ON COLUMN sales.invoices.CustomerID IS 'Customer for this invoice';
COMMENT ON COLUMN sales.invoices.BillToCustomerID IS 'Bill to customer for this invoice (invoices might be billed to a head office)';
COMMENT ON COLUMN sales.invoices.OrderID IS 'Sales order (if any) for this invoice';
COMMENT ON COLUMN sales.invoices.DeliveryMethodID IS 'How these stock items are being delivered';
COMMENT ON COLUMN sales.invoices.ContactPersonID IS 'Customer contact for this invoice';
COMMENT ON COLUMN sales.invoices.AccountsPersonID IS 'Customer accounts contact for this invoice';
COMMENT ON COLUMN sales.invoices.SalespersonPersonID IS 'Salesperson for this invoice';
COMMENT ON COLUMN sales.invoices.PackedByPersonID IS 'Person who packed this shipment (or checked the packing)';
COMMENT ON COLUMN sales.invoices.InvoiceDate IS 'Date that this invoice was raised';
COMMENT ON COLUMN sales.invoices.CustomerPurchaseOrderNumber IS 'Purchase Order Number received from customer';
COMMENT ON COLUMN sales.invoices.IsCreditNote IS 'Is this a credit note (rather than an invoice)';
COMMENT ON COLUMN sales.invoices.CreditNoteReason IS 'Reason that this credit note needed to be generated (if applicable)';
COMMENT ON COLUMN sales.invoices.Comments IS 'Any comments related to this invoice (sent to customer)';
COMMENT ON COLUMN sales.invoices.DeliveryInstructions IS 'Any comments related to delivery (sent to customer)';
COMMENT ON COLUMN sales.invoices.InternalComments IS 'Any internal comments related to this invoice (not sent to the customer)';
COMMENT ON COLUMN sales.invoices.TotalDryItems IS 'Total number of dry packages (information for the delivery driver)';
COMMENT ON COLUMN sales.invoices.TotalChillerItems IS 'Total number of chiller packages (information for the delivery driver)';
COMMENT ON COLUMN sales.invoices.DeliveryRun IS 'Delivery run for this shipment';
COMMENT ON COLUMN sales.invoices.RunPosition IS 'Position in the delivery run for this shipment';
COMMENT ON COLUMN sales.invoices.ReturnedDeliveryData IS 'JSON-structured data returned from delivery devices for deliveries made directly by the organization';
COMMENT ON COLUMN sales.invoices.ConfirmedDeliveryTime IS 'Confirmed delivery date and time promoted from JSON delivery data';
COMMENT ON COLUMN sales.invoices.ConfirmedReceivedBy IS 'Confirmed receiver promoted from JSON delivery data';
