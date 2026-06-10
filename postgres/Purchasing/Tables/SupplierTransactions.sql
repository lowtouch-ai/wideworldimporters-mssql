CREATE SCHEMA IF NOT EXISTS purchasing;
CREATE SCHEMA IF NOT EXISTS sequences;

CREATE SEQUENCE IF NOT EXISTS sequences.transaction_id_seq START 714101 INCREMENT 1;

CREATE TABLE purchasing.suppliertransactions (
    SupplierTransactionID INTEGER        DEFAULT nextval('sequences.transaction_id_seq') NOT NULL,
    SupplierID            INTEGER        NOT NULL,
    TransactionTypeID     INTEGER        NOT NULL,
    PurchaseOrderID       INTEGER        NULL,
    PaymentMethodID       INTEGER        NULL,
    SupplierInvoiceNumber VARCHAR(20)    NULL,
    TransactionDate       DATE           NOT NULL,
    AmountExcludingTax    NUMERIC(18, 2) NOT NULL,
    TaxAmount             NUMERIC(18, 2) NOT NULL,
    TransactionAmount     NUMERIC(18, 2) NOT NULL,
    OutstandingBalance    NUMERIC(18, 2) NOT NULL,
    FinalizationDate      DATE           NULL,
    IsFinalized           BOOLEAN        GENERATED ALWAYS AS (FinalizationDate IS NOT NULL) STORED,
    LastEditedBy          INTEGER        NOT NULL,
    LastEditedWhen        TIMESTAMP(6)   DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT PK_Purchasing_SupplierTransactions PRIMARY KEY (SupplierTransactionID),
    CONSTRAINT FK_Purchasing_SupplierTransactions_Application_People FOREIGN KEY (LastEditedBy) REFERENCES application.people (PersonID),
    CONSTRAINT FK_Purchasing_SupplierTransactions_PaymentMethodID_Application_PaymentMethods FOREIGN KEY (PaymentMethodID) REFERENCES application.paymentmethods (PaymentMethodID),
    CONSTRAINT FK_Purchasing_SupplierTransactions_PurchaseOrderID_Purchasing_PurchaseOrders FOREIGN KEY (PurchaseOrderID) REFERENCES purchasing.purchaseorders (PurchaseOrderID),
    CONSTRAINT FK_Purchasing_SupplierTransactions_SupplierID_Purchasing_Suppliers FOREIGN KEY (SupplierID) REFERENCES purchasing.suppliers (SupplierID),
    CONSTRAINT FK_Purchasing_SupplierTransactions_TransactionTypeID_Application_TransactionTypes FOREIGN KEY (TransactionTypeID) REFERENCES application.transactiontypes (TransactionTypeID)
);

CREATE INDEX CX_Purchasing_SupplierTransactions ON purchasing.suppliertransactions (TransactionDate ASC);
CREATE INDEX FK_Purchasing_SupplierTransactions_SupplierID ON purchasing.suppliertransactions (SupplierID ASC);
CREATE INDEX FK_Purchasing_SupplierTransactions_TransactionTypeID ON purchasing.suppliertransactions (TransactionTypeID ASC);
CREATE INDEX FK_Purchasing_SupplierTransactions_PurchaseOrderID ON purchasing.suppliertransactions (PurchaseOrderID ASC);
CREATE INDEX FK_Purchasing_SupplierTransactions_PaymentMethodID ON purchasing.suppliertransactions (PaymentMethodID ASC);
CREATE INDEX IX_Purchasing_SupplierTransactions_IsFinalized ON purchasing.suppliertransactions (IsFinalized ASC);

COMMENT ON TABLE purchasing.suppliertransactions IS 'All financial transactions that are supplier-related';
COMMENT ON COLUMN purchasing.suppliertransactions.SupplierTransactionID IS 'Numeric ID used to refer to a supplier transaction within the database';
COMMENT ON COLUMN purchasing.suppliertransactions.SupplierID IS 'Supplier for this transaction';
COMMENT ON COLUMN purchasing.suppliertransactions.TransactionTypeID IS 'Type of transaction';
COMMENT ON COLUMN purchasing.suppliertransactions.PurchaseOrderID IS 'ID of an purchase order (for transactions associated with a purchase order)';
COMMENT ON COLUMN purchasing.suppliertransactions.PaymentMethodID IS 'ID of a payment method (for transactions involving payments)';
COMMENT ON COLUMN purchasing.suppliertransactions.SupplierInvoiceNumber IS 'Invoice number for an invoice received from the supplier';
COMMENT ON COLUMN purchasing.suppliertransactions.TransactionDate IS 'Date for the transaction';
COMMENT ON COLUMN purchasing.suppliertransactions.AmountExcludingTax IS 'Transaction amount (excluding tax)';
COMMENT ON COLUMN purchasing.suppliertransactions.TaxAmount IS 'Tax amount calculated';
COMMENT ON COLUMN purchasing.suppliertransactions.TransactionAmount IS 'Transaction amount (including tax)';
COMMENT ON COLUMN purchasing.suppliertransactions.OutstandingBalance IS 'Amount still outstanding for this transaction';
COMMENT ON COLUMN purchasing.suppliertransactions.FinalizationDate IS 'Date that this transaction was finalized (if it has been)';
COMMENT ON COLUMN purchasing.suppliertransactions.IsFinalized IS 'Is this transaction finalized (invoices, credits and payments have been matched)';
