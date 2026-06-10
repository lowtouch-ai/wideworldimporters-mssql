CREATE SCHEMA IF NOT EXISTS sales;
CREATE SCHEMA IF NOT EXISTS sequences;

CREATE SEQUENCE IF NOT EXISTS sequences.order_line_id_seq START 1 INCREMENT 1;

CREATE TABLE sales.orderlines (
    OrderLineID          INTEGER         DEFAULT nextval('sequences.order_line_id_seq') NOT NULL,
    OrderID              INTEGER         NOT NULL,
    StockItemID          INTEGER         NOT NULL,
    Description          VARCHAR(100)    NOT NULL,
    PackageTypeID        INTEGER         NOT NULL,
    Quantity             INTEGER         NOT NULL,
    UnitPrice            NUMERIC(18, 2)  NULL,
    TaxRate              NUMERIC(18, 3)  NOT NULL,
    PickedQuantity       INTEGER         NOT NULL,
    PickingCompletedWhen TIMESTAMP(6)    NULL,
    LastEditedBy         INTEGER         NOT NULL,
    LastEditedWhen       TIMESTAMP(6)    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Sales_OrderLines PRIMARY KEY (OrderLineID),
    CONSTRAINT FK_Sales_OrderLines_Application_People FOREIGN KEY (LastEditedBy) REFERENCES application.people (PersonID),
    CONSTRAINT FK_Sales_OrderLines_OrderID_Sales_Orders FOREIGN KEY (OrderID) REFERENCES sales.orders (OrderID),
    CONSTRAINT FK_Sales_OrderLines_PackageTypeID_Warehouse_PackageTypes FOREIGN KEY (PackageTypeID) REFERENCES warehouse.packagetypes (PackageTypeID),
    CONSTRAINT FK_Sales_OrderLines_StockItemID_Warehouse_StockItems FOREIGN KEY (StockItemID) REFERENCES warehouse.stockitems (StockItemID)
);

CREATE INDEX FK_Sales_OrderLines_OrderID ON sales.orderlines (OrderID ASC);
CREATE INDEX FK_Sales_OrderLines_PackageTypeID ON sales.orderlines (PackageTypeID ASC);
CREATE INDEX IX_Sales_OrderLines_AllocatedStockItems ON sales.orderlines (StockItemID ASC) INCLUDE (PickedQuantity);
CREATE INDEX IX_Sales_OrderLines_Perf_20160301_01 ON sales.orderlines (PickingCompletedWhen ASC, OrderID ASC, OrderLineID ASC) INCLUDE (Quantity, StockItemID);
CREATE INDEX IX_Sales_OrderLines_Perf_20160301_02 ON sales.orderlines (StockItemID ASC, PickingCompletedWhen ASC) INCLUDE (OrderID, PickedQuantity);
-- COLUMNSTORE index omitted: no PostgreSQL equivalent

COMMENT ON TABLE sales.orderlines IS 'Detail lines from customer orders';
COMMENT ON COLUMN sales.orderlines.OrderLineID IS 'Numeric ID used for reference to a line on an Order within the database';
COMMENT ON COLUMN sales.orderlines.OrderID IS 'Order that this line is associated with';
COMMENT ON COLUMN sales.orderlines.StockItemID IS 'Stock item for this order line (FK not indexed as separate index exists)';
COMMENT ON COLUMN sales.orderlines.Description IS 'Description of the item supplied (Usually the stock item name but can be overridden)';
COMMENT ON COLUMN sales.orderlines.PackageTypeID IS 'Type of package to be supplied';
COMMENT ON COLUMN sales.orderlines.Quantity IS 'Quantity to be supplied';
COMMENT ON COLUMN sales.orderlines.UnitPrice IS 'Unit price to be charged';
COMMENT ON COLUMN sales.orderlines.TaxRate IS 'Tax rate to be applied';
COMMENT ON COLUMN sales.orderlines.PickedQuantity IS 'Quantity picked from stock';
COMMENT ON COLUMN sales.orderlines.PickingCompletedWhen IS 'When was picking of this line completed?';
