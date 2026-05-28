CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE VIEW webapi.buying_groups AS
SELECT BuyingGroupID, BuyingGroupName
FROM sales.buyinggroups;
