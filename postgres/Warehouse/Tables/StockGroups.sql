CREATE SCHEMA IF NOT EXISTS warehouse;
CREATE SCHEMA IF NOT EXISTS sequences;

CREATE SEQUENCE IF NOT EXISTS sequences.stock_group_id_seq START 11 INCREMENT 1;

CREATE TABLE warehouse.stockgroups (
    StockGroupID   INTEGER      DEFAULT nextval('sequences.stock_group_id_seq') NOT NULL,
    StockGroupName VARCHAR(50)  NOT NULL,
    LastEditedBy   INTEGER      NOT NULL,
    ValidFrom      TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ValidTo        TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Warehouse_StockGroups PRIMARY KEY (StockGroupID),
    CONSTRAINT FK_Warehouse_StockGroups_Application_People FOREIGN KEY (LastEditedBy) REFERENCES application.people (PersonID),
    CONSTRAINT UQ_Warehouse_StockGroups_StockGroupName UNIQUE (StockGroupName)
);

COMMENT ON TABLE warehouse.stockgroups IS 'Groups for categorizing stock items (ie: novelties, toys, edible novelties, etc.)';
COMMENT ON COLUMN warehouse.stockgroups.StockGroupID IS 'Numeric ID used for reference to a stock group within the database';
COMMENT ON COLUMN warehouse.stockgroups.StockGroupName IS 'Full name of groups used to categorize stock items';
