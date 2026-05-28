CREATE SCHEMA IF NOT EXISTS warehouse;

CREATE TABLE warehouse.stock_groups_archive (
    StockGroupID   INTEGER      NOT NULL,
    StockGroupName VARCHAR(50)  NOT NULL,
    LastEditedBy   INTEGER      NOT NULL,
    ValidFrom      TIMESTAMP(6) NOT NULL,
    ValidTo        TIMESTAMP(6) NOT NULL
);

CREATE INDEX ix_StockGroups_Archive ON warehouse.stock_groups_archive (ValidTo ASC, ValidFrom ASC);
