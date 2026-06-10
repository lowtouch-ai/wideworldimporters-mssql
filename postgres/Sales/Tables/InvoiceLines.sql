CREATE SCHEMA IF NOT EXISTS sales;
CREATE SCHEMA IF NOT EXISTS sequences;

CREATE SEQUENCE IF NOT EXISTS sequences.invoice_line_id_seq START 1 INCREMENT 1;

CREATE TABLE sales.invoicelines (
    InvoiceLineID  INTEGER         DEFAULT nextval('sequences.invoice_line_id_seq') NOT NULL,
    InvoiceID      INTEGER         NOT NULL,
    StockItemID    INTEGER         NOT NULL,
    Description    VARCHAR(100)    NOT NULL,
    PackageTypeID  INTEGER         NOT NULL,
    Quantity       INTEGER         NOT NULL,
    UnitPrice      NUMERIC(18, 2)  NULL,
    TaxRate        NUMERIC(18, 3)  NOT NULL,
    TaxAmount      NUMERIC(18, 2)  NOT NULL,
    LineProfit     NUMERIC(18, 2)  NOT NULL,
    ExtendedPrice  NUMERIC(18, 2)  NOT NULL,
    LastEditedBy   INTEGER         NOT NULL,
    LastEditedWhen TIMESTAMP(6)    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Sales_InvoiceLines PRIMARY KEY (InvoiceLineID),
    CONSTRAINT FK_Sales_InvoiceLines_Application_People FOREIGN KEY (LastEditedBy) REFERENCES application.people (PersonID),
    CONSTRAINT FK_Sales_InvoiceLines_InvoiceID_Sales_Invoices FOREIGN KEY (InvoiceID) REFERENCES sales.invoices (InvoiceID),
    CONSTRAINT FK_Sales_InvoiceLines_PackageTypeID_Warehouse_PackageTypes FOREIGN KEY (PackageTypeID) REFERENCES warehouse.packagetypes (PackageTypeID),
    CONSTRAINT FK_Sales_InvoiceLines_StockItemID_Warehouse_StockItems FOREIGN KEY (StockItemID) REFERENCES warehouse.stockitems (StockItemID)
);

CREATE INDEX FK_Sales_InvoiceLines_InvoiceID ON sales.invoicelines (InvoiceID ASC);
CREATE INDEX FK_Sales_InvoiceLines_StockItemID ON sales.invoicelines (StockItemID ASC);
CREATE INDEX FK_Sales_InvoiceLines_PackageTypeID ON sales.invoicelines (PackageTypeID ASC);
-- COLUMNSTORE index omitted: no PostgreSQL equivalent

COMMENT ON TABLE sales.invoicelines IS 'Detail lines from customer invoices';
COMMENT ON COLUMN sales.invoicelines.InvoiceLineID IS 'Numeric ID used for reference to a line on an invoice within the database';
COMMENT ON COLUMN sales.invoicelines.InvoiceID IS 'Invoice that this line is associated with';
COMMENT ON COLUMN sales.invoicelines.StockItemID IS 'Stock item for this invoice line';
COMMENT ON COLUMN sales.invoicelines.Description IS 'Description of the item supplied (Usually the stock item name but can be overridden)';
COMMENT ON COLUMN sales.invoicelines.PackageTypeID IS 'Type of package supplied';
COMMENT ON COLUMN sales.invoicelines.Quantity IS 'Quantity supplied';
COMMENT ON COLUMN sales.invoicelines.UnitPrice IS 'Unit price charged';
COMMENT ON COLUMN sales.invoicelines.TaxRate IS 'Tax rate to be applied';
COMMENT ON COLUMN sales.invoicelines.TaxAmount IS 'Tax amount calculated';
COMMENT ON COLUMN sales.invoicelines.LineProfit IS 'Profit made on this line item at current cost price';
COMMENT ON COLUMN sales.invoicelines.ExtendedPrice IS 'Extended line price charged';
