CREATE SCHEMA IF NOT EXISTS warehouse;
CREATE SCHEMA IF NOT EXISTS sequences;

CREATE SEQUENCE IF NOT EXISTS sequences.stock_item_stock_group_id_seq START 885 INCREMENT 1;

CREATE TABLE warehouse.stockitemstockgroups (
    StockItemStockGroupID INTEGER      DEFAULT nextval('sequences.stock_item_stock_group_id_seq') NOT NULL,
    StockItemID           INTEGER      NOT NULL,
    StockGroupID          INTEGER      NOT NULL,
    LastEditedBy          INTEGER      NOT NULL,
    LastEditedWhen        TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT PK_Warehouse_StockItemStockGroups PRIMARY KEY (StockItemStockGroupID),
    CONSTRAINT FK_Warehouse_StockItemStockGroups_Application_People FOREIGN KEY (LastEditedBy) REFERENCES application.people (PersonID),
    CONSTRAINT FK_Warehouse_StockItemStockGroups_StockGroupID_Warehouse_StockGroups FOREIGN KEY (StockGroupID) REFERENCES warehouse.stockgroups (StockGroupID),
    CONSTRAINT FK_Warehouse_StockItemStockGroups_StockItemID_Warehouse_StockItems FOREIGN KEY (StockItemID) REFERENCES warehouse.stockitems (StockItemID),
    CONSTRAINT UQ_StockItemStockGroups_StockGroupID_Lookup UNIQUE (StockGroupID, StockItemID),
    CONSTRAINT UQ_StockItemStockGroups_StockItemID_Lookup UNIQUE (StockItemID, StockGroupID)
);

COMMENT ON TABLE warehouse.stockitemstockgroups IS 'Which stock items are in which stock groups';
COMMENT ON COLUMN warehouse.stockitemstockgroups.StockItemStockGroupID IS 'Internal reference for this linking row';
COMMENT ON COLUMN warehouse.stockitemstockgroups.StockItemID IS 'Stock item assigned to this stock group (FK indexed via unique constraint)';
COMMENT ON COLUMN warehouse.stockitemstockgroups.StockGroupID IS 'StockGroup assigned to this stock item (FK indexed via unique constraint)';
