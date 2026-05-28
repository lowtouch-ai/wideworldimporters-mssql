CREATE SCHEMA IF NOT EXISTS sales;

-- Partition scheme PS_TransactionDate omitted: no PostgreSQL equivalent
-- IsFinalized was a PERSISTED computed column; converted to GENERATED ALWAYS AS STORED

CREATE TABLE sales.customertransactions
(
    CustomerTransactionID INTEGER        DEFAULT nextval('sequences.transaction_id_seq') NOT NULL,
    CustomerID            INTEGER        NOT NULL,
    TransactionTypeID     INTEGER        NOT NULL,
    InvoiceID             INTEGER        NULL,
    PaymentMethodID       INTEGER        NULL,
    TransactionDate       DATE           NOT NULL,
    AmountExcludingTax    NUMERIC(18, 2) NOT NULL,
    TaxAmount             NUMERIC(18, 2) NOT NULL,
    TransactionAmount     NUMERIC(18, 2) NOT NULL,
    OutstandingBalance    NUMERIC(18, 2) NOT NULL,
    FinalizationDate      DATE           NULL,
    IsFinalized           BOOLEAN        GENERATED ALWAYS AS (CASE WHEN FinalizationDate IS NULL THEN FALSE ELSE TRUE END) STORED,
    LastEditedBy          INTEGER        NOT NULL,
    LastEditedWhen        TIMESTAMP(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Sales_CustomerTransactions PRIMARY KEY (CustomerTransactionID),
    CONSTRAINT FK_Sales_CustomerTransactions_Application_People FOREIGN KEY (LastEditedBy) REFERENCES application.people (PersonID),
    CONSTRAINT FK_Sales_CustomerTransactions_CustomerID_Sales_Customers FOREIGN KEY (CustomerID) REFERENCES sales.customers (CustomerID),
    CONSTRAINT FK_Sales_CustomerTransactions_InvoiceID_Sales_Invoices FOREIGN KEY (InvoiceID) REFERENCES sales.invoices (InvoiceID),
    CONSTRAINT FK_Sales_CustomerTransactions_PaymentMethodID_Application_PaymentMethods FOREIGN KEY (PaymentMethodID) REFERENCES application.paymentmethods (PaymentMethodID),
    CONSTRAINT FK_Sales_CustomerTransactions_TransactionTypeID_Application_TransactionTypes FOREIGN KEY (TransactionTypeID) REFERENCES application.transactiontypes (TransactionTypeID)
);

-- 5 index-level extended properties omitted (no PostgreSQL equivalent for index comments)
CREATE INDEX CX_Sales_CustomerTransactions ON sales.customertransactions (TransactionDate ASC);
CREATE INDEX FK_Sales_CustomerTransactions_CustomerID ON sales.customertransactions (CustomerID ASC);
CREATE INDEX FK_Sales_CustomerTransactions_TransactionTypeID ON sales.customertransactions (TransactionTypeID ASC);
CREATE INDEX FK_Sales_CustomerTransactions_InvoiceID ON sales.customertransactions (InvoiceID ASC);
CREATE INDEX FK_Sales_CustomerTransactions_PaymentMethodID ON sales.customertransactions (PaymentMethodID ASC);
CREATE INDEX IX_Sales_CustomerTransactions_IsFinalized ON sales.customertransactions (IsFinalized ASC);

COMMENT ON TABLE sales.customertransactions IS 'All financial transactions that are customer-related';
COMMENT ON COLUMN sales.customertransactions.CustomerTransactionID IS 'Numeric ID used to refer to a customer transaction within the database';
COMMENT ON COLUMN sales.customertransactions.CustomerID IS 'Customer for this transaction';
COMMENT ON COLUMN sales.customertransactions.TransactionTypeID IS 'Type of transaction';
COMMENT ON COLUMN sales.customertransactions.InvoiceID IS 'ID of an invoice (for transactions associated with an invoice)';
COMMENT ON COLUMN sales.customertransactions.PaymentMethodID IS 'ID of a payment method (for transactions involving payments)';
COMMENT ON COLUMN sales.customertransactions.TransactionDate IS 'Date for the transaction';
COMMENT ON COLUMN sales.customertransactions.AmountExcludingTax IS 'Transaction amount (excluding tax)';
COMMENT ON COLUMN sales.customertransactions.TaxAmount IS 'Tax amount calculated';
COMMENT ON COLUMN sales.customertransactions.TransactionAmount IS 'Transaction amount (including tax)';
COMMENT ON COLUMN sales.customertransactions.OutstandingBalance IS 'Amount still outstanding for this transaction';
COMMENT ON COLUMN sales.customertransactions.FinalizationDate IS 'Date that this transaction was finalized (if it has been)';
COMMENT ON COLUMN sales.customertransactions.IsFinalized IS 'Is this transaction finalized (invoices, credits and payments have been matched)';
