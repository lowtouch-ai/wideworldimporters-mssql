CREATE SCHEMA IF NOT EXISTS purchasing;
CREATE SCHEMA IF NOT EXISTS sequences;

CREATE SEQUENCE IF NOT EXISTS sequences.purchase_order_line_id_seq START 17086 INCREMENT 1;

CREATE TABLE purchasing.purchaseorderlines (
    PurchaseOrderLineID       INTEGER        DEFAULT nextval('sequences.purchase_order_line_id_seq') NOT NULL,
    PurchaseOrderID           INTEGER        NOT NULL,
    StockItemID               INTEGER        NOT NULL,
    OrderedOuters             INTEGER        NOT NULL,
    Description               VARCHAR(100)   NOT NULL,
    ReceivedOuters            INTEGER        NOT NULL,
    PackageTypeID             INTEGER        NOT NULL,
    ExpectedUnitPricePerOuter NUMERIC(18, 2) NULL,
    LastReceiptDate           DATE           NULL,
    IsOrderLineFinalized      BOOLEAN        NOT NULL,
    LastEditedBy              INTEGER        NOT NULL,
    LastEditedWhen            TIMESTAMP(6)   DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT PK_Purchasing_PurchaseOrderLines PRIMARY KEY (PurchaseOrderLineID),
    CONSTRAINT FK_Purchasing_PurchaseOrderLines_Application_People FOREIGN KEY (LastEditedBy) REFERENCES application.people (PersonID),
    CONSTRAINT FK_Purchasing_PurchaseOrderLines_PackageTypeID_Warehouse_PackageTypes FOREIGN KEY (PackageTypeID) REFERENCES warehouse.packagetypes (PackageTypeID),
    CONSTRAINT FK_Purchasing_PurchaseOrderLines_PurchaseOrderID_Purchasing_PurchaseOrders FOREIGN KEY (PurchaseOrderID) REFERENCES purchasing.purchaseorders (PurchaseOrderID),
    CONSTRAINT FK_Purchasing_PurchaseOrderLines_StockItemID_Warehouse_StockItems FOREIGN KEY (StockItemID) REFERENCES warehouse.stockitems (StockItemID)
);

CREATE INDEX FK_Purchasing_PurchaseOrderLines_PurchaseOrderID ON purchasing.purchaseorderlines (PurchaseOrderID ASC);
CREATE INDEX FK_Purchasing_PurchaseOrderLines_StockItemID ON purchasing.purchaseorderlines (StockItemID ASC);
CREATE INDEX FK_Purchasing_PurchaseOrderLines_PackageTypeID ON purchasing.purchaseorderlines (PackageTypeID ASC);
CREATE INDEX IX_Purchasing_PurchaseOrderLines_Perf_20160301_4 ON purchasing.purchaseorderlines (IsOrderLineFinalized ASC, StockItemID ASC) INCLUDE (OrderedOuters, ReceivedOuters);

COMMENT ON TABLE purchasing.purchaseorderlines IS 'Detail lines from supplier purchase orders';
COMMENT ON COLUMN purchasing.purchaseorderlines.PurchaseOrderLineID IS 'Numeric ID used for reference to a line on a purchase order within the database';
COMMENT ON COLUMN purchasing.purchaseorderlines.PurchaseOrderID IS 'Purchase order that this line is associated with';
COMMENT ON COLUMN purchasing.purchaseorderlines.StockItemID IS 'Stock item for this purchase order line';
COMMENT ON COLUMN purchasing.purchaseorderlines.OrderedOuters IS 'Quantity of the stock item that is ordered';
COMMENT ON COLUMN purchasing.purchaseorderlines.Description IS 'Description of the item to be supplied (Often the stock item name but could be supplier description)';
COMMENT ON COLUMN purchasing.purchaseorderlines.ReceivedOuters IS 'Total quantity of the stock item that has been received so far';
COMMENT ON COLUMN purchasing.purchaseorderlines.PackageTypeID IS 'Type of package received';
COMMENT ON COLUMN purchasing.purchaseorderlines.ExpectedUnitPricePerOuter IS 'The unit price that we expect to be charged';
COMMENT ON COLUMN purchasing.purchaseorderlines.LastReceiptDate IS 'The last date on which this stock item was received for this purchase order';
COMMENT ON COLUMN purchasing.purchaseorderlines.IsOrderLineFinalized IS 'Is this purchase order line now considered finalized? (Receipted quantities and weights are often not precise)';
