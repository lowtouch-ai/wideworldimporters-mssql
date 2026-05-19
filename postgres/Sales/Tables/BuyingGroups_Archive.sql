CREATE SCHEMA IF NOT EXISTS sales;

CREATE TABLE sales.buyinggroups_archive (
    BuyingGroupID   INTEGER      NOT NULL,
    BuyingGroupName VARCHAR(50)  NOT NULL,
    LastEditedBy    INTEGER      NOT NULL,
    ValidFrom       TIMESTAMP(6) NOT NULL,
    ValidTo         TIMESTAMP(6) NOT NULL
);

CREATE INDEX ix_BuyingGroups_Archive ON sales.buyinggroups_archive (ValidTo ASC, ValidFrom ASC);
