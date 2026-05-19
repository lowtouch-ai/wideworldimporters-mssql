CREATE SCHEMA IF NOT EXISTS warehouse;

-- CLUSTERED COLUMNSTORE index omitted: no PostgreSQL equivalent

CREATE TABLE warehouse.stockitemtransactions
(
    StockItemTransactionID  INTEGER        DEFAULT nextval('sequences.transaction_id_seq') NOT NULL,
    StockItemID             INTEGER        NOT NULL,
    TransactionTypeID       INTEGER        NOT NULL,
    CustomerID              INTEGER        NULL,
    InvoiceID               INTEGER        NULL,
    SupplierID              INTEGER        NULL,
    PurchaseOrderID         INTEGER        NULL,
    TransactionOccurredWhen TIMESTAMP(6)   NOT NULL,
    Quantity                NUMERIC(18, 3) NOT NULL,
    LastEditedBy            INTEGER        NOT NULL,
    LastEditedWhen          TIMESTAMP(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Warehouse_StockItemTransactions PRIMARY KEY (StockItemTransactionID),
    CONSTRAINT FK_Warehouse_StockItemTransactions_Application_People FOREIGN KEY (LastEditedBy) REFERENCES application.people (PersonID),
    CONSTRAINT FK_Warehouse_StockItemTransactions_CustomerID_Sales_Customers FOREIGN KEY (CustomerID) REFERENCES sales.customers (CustomerID),
    CONSTRAINT FK_Warehouse_StockItemTransactions_InvoiceID_Sales_Invoices FOREIGN KEY (InvoiceID) REFERENCES sales.invoices (InvoiceID),
    CONSTRAINT FK_Warehouse_StockItemTransactions_PurchaseOrderID_Purchasing_PurchaseOrders FOREIGN KEY (PurchaseOrderID) REFERENCES purchasing.purchaseorders (PurchaseOrderID),
    CONSTRAINT FK_Warehouse_StockItemTransactions_StockItemID_Warehouse_StockItems FOREIGN KEY (StockItemID) REFERENCES warehouse.stockitems (StockItemID),
    CONSTRAINT FK_Warehouse_StockItemTransactions_SupplierID_Purchasing_Suppliers FOREIGN KEY (SupplierID) REFERENCES purchasing.suppliers (SupplierID),
    CONSTRAINT FK_Warehouse_StockItemTransactions_TransactionTypeID_Application_TransactionTypes FOREIGN KEY (TransactionTypeID) REFERENCES application.transactiontypes (TransactionTypeID)
);

-- 6 index-level extended properties omitted (no PostgreSQL equivalent for index comments)
CREATE INDEX FK_Warehouse_StockItemTransactions_StockItemID ON warehouse.stockitemtransactions (StockItemID ASC);
CREATE INDEX FK_Warehouse_StockItemTransactions_TransactionTypeID ON warehouse.stockitemtransactions (TransactionTypeID ASC);
CREATE INDEX FK_Warehouse_StockItemTransactions_CustomerID ON warehouse.stockitemtransactions (CustomerID ASC);
CREATE INDEX FK_Warehouse_StockItemTransactions_InvoiceID ON warehouse.stockitemtransactions (InvoiceID ASC);
CREATE INDEX FK_Warehouse_StockItemTransactions_SupplierID ON warehouse.stockitemtransactions (SupplierID ASC);
CREATE INDEX FK_Warehouse_StockItemTransactions_PurchaseOrderID ON warehouse.stockitemtransactions (PurchaseOrderID ASC);

COMMENT ON TABLE warehouse.stockitemtransactions IS 'Transactions covering all movements of all stock items';
COMMENT ON COLUMN warehouse.stockitemtransactions.StockItemTransactionID IS 'Numeric ID used to refer to a stock item transaction within the database';
COMMENT ON COLUMN warehouse.stockitemtransactions.StockItemID IS 'StockItem for this transaction';
COMMENT ON COLUMN warehouse.stockitemtransactions.TransactionTypeID IS 'Type of transaction';
COMMENT ON COLUMN warehouse.stockitemtransactions.CustomerID IS 'Customer for this transaction (if applicable)';
COMMENT ON COLUMN warehouse.stockitemtransactions.InvoiceID IS 'ID of an invoice (for transactions associated with an invoice)';
COMMENT ON COLUMN warehouse.stockitemtransactions.SupplierID IS 'Supplier for this stock transaction (if applicable)';
COMMENT ON COLUMN warehouse.stockitemtransactions.PurchaseOrderID IS 'ID of an purchase order (for transactions associated with a purchase order)';
COMMENT ON COLUMN warehouse.stockitemtransactions.TransactionOccurredWhen IS 'Date and time when the transaction occurred';
COMMENT ON COLUMN warehouse.stockitemtransactions.Quantity IS 'Quantity of stock movement (positive is incoming stock, negative is outgoing)';
