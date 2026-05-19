CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE VIEW webapi.stock_groups AS
SELECT StockGroupID, StockGroupName
FROM warehouse.stock_groups;
