CREATE SCHEMA IF NOT EXISTS warehouse;

CREATE TABLE warehouse.stockitemholdings (
    StockItemID           INTEGER        NOT NULL,
    QuantityOnHand        INTEGER        NOT NULL,
    BinLocation           VARCHAR(20)    NOT NULL,
    LastStocktakeQuantity INTEGER        NOT NULL,
    LastCostPrice         NUMERIC(18, 2) NOT NULL,
    ReorderLevel          INTEGER        NOT NULL,
    TargetStockLevel      INTEGER        NOT NULL,
    LastEditedBy          INTEGER        NOT NULL,
    LastEditedWhen        TIMESTAMP(6)   DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT PK_Warehouse_StockItemHoldings PRIMARY KEY (StockItemID),
    CONSTRAINT FK_Warehouse_StockItemHoldings_Application_People FOREIGN KEY (LastEditedBy) REFERENCES application.people (PersonID),
    CONSTRAINT PKFK_Warehouse_StockItemHoldings_StockItemID_Warehouse_StockItems FOREIGN KEY (StockItemID) REFERENCES warehouse.stockitems (StockItemID)
);

COMMENT ON TABLE warehouse.stockitemholdings IS 'Non-temporal attributes for stock items';
COMMENT ON COLUMN warehouse.stockitemholdings.StockItemID IS 'ID of the stock item that this holding relates to (this table holds non-temporal columns for stock)';
COMMENT ON COLUMN warehouse.stockitemholdings.QuantityOnHand IS 'Quantity currently on hand (if tracked)';
COMMENT ON COLUMN warehouse.stockitemholdings.BinLocation IS 'Bin location (ie location of this stock item within the depot)';
COMMENT ON COLUMN warehouse.stockitemholdings.LastStocktakeQuantity IS 'Quantity at last stocktake (if tracked)';
COMMENT ON COLUMN warehouse.stockitemholdings.LastCostPrice IS 'Unit cost price the last time this stock item was purchased';
COMMENT ON COLUMN warehouse.stockitemholdings.ReorderLevel IS 'Quantity below which reordering should take place';
COMMENT ON COLUMN warehouse.stockitemholdings.TargetStockLevel IS 'Typical quantity ordered';
