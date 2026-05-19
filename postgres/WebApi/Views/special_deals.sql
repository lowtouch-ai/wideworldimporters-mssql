CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE VIEW webapi.special_deals AS
SELECT
    deal.SpecialDealID,
    deal.DealDescription,
    deal.StartDate,
    deal.EndDate,
    deal.DiscountAmount,
    deal.DiscountPercentage,
    deal.UnitPrice,
    si.StockItemName,
    si.Brand,
    si.Size,
    c.CustomerName,
    bg.BuyingGroupName,
    cat.CustomerCategoryName,
    deal.StockItemID,
    deal.CustomerID,
    deal.BuyingGroupID,
    deal.CustomerCategoryID,
    deal.StockGroupID
FROM sales.specialdeals AS deal
    LEFT JOIN warehouse.stockitems AS si ON deal.StockItemID = si.StockItemID
    LEFT JOIN sales.customers AS c ON deal.CustomerID = c.CustomerID
    LEFT JOIN sales.customercategories AS cat ON deal.CustomerCategoryID = cat.CustomerCategoryID
    LEFT JOIN sales.buyinggroups AS bg ON deal.BuyingGroupID = bg.BuyingGroupID;
