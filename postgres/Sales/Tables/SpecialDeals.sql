CREATE SCHEMA IF NOT EXISTS sales;
CREATE SCHEMA IF NOT EXISTS sequences;

CREATE SEQUENCE IF NOT EXISTS sequences.special_deal_id_seq START 1 INCREMENT 1;

CREATE TABLE sales.specialdeals (
    SpecialDealID      INTEGER         DEFAULT nextval('sequences.special_deal_id_seq') NOT NULL,
    StockItemID        INTEGER         NULL,
    CustomerID         INTEGER         NULL,
    BuyingGroupID      INTEGER         NULL,
    CustomerCategoryID INTEGER         NULL,
    StockGroupID       INTEGER         NULL,
    DealDescription    VARCHAR(30)     NOT NULL,
    StartDate          DATE            NOT NULL,
    EndDate            DATE            NOT NULL,
    DiscountAmount     NUMERIC(18, 2)  NULL,
    DiscountPercentage NUMERIC(18, 3)  NULL,
    UnitPrice          NUMERIC(18, 2)  NULL,
    LastEditedBy       INTEGER         NOT NULL,
    LastEditedWhen     TIMESTAMP(6)    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Sales_SpecialDeals PRIMARY KEY (SpecialDealID),
    CONSTRAINT CK_Sales_SpecialDeals_Exactly_One_NOT_NULL_Pricing_Option_Is_Required CHECK (
        (CASE WHEN DiscountAmount IS NULL THEN 0 ELSE 1 END
         + CASE WHEN DiscountPercentage IS NULL THEN 0 ELSE 1 END
         + CASE WHEN UnitPrice IS NULL THEN 0 ELSE 1 END) = 1
    ),
    CONSTRAINT CK_Sales_SpecialDeals_Unit_Price_Deal_Requires_Special_StockItem CHECK (
        StockItemID IS NOT NULL AND UnitPrice IS NOT NULL OR UnitPrice IS NULL
    ),
    CONSTRAINT FK_Sales_SpecialDeals_Application_People FOREIGN KEY (LastEditedBy) REFERENCES application.people (PersonID),
    CONSTRAINT FK_Sales_SpecialDeals_BuyingGroupID_Sales_BuyingGroups FOREIGN KEY (BuyingGroupID) REFERENCES sales.buyinggroups (BuyingGroupID),
    CONSTRAINT FK_Sales_SpecialDeals_CustomerCategoryID_Sales_CustomerCategories FOREIGN KEY (CustomerCategoryID) REFERENCES sales.customercategories (CustomerCategoryID),
    CONSTRAINT FK_Sales_SpecialDeals_CustomerID_Sales_Customers FOREIGN KEY (CustomerID) REFERENCES sales.customers (CustomerID),
    CONSTRAINT FK_Sales_SpecialDeals_StockGroupID_Warehouse_StockGroups FOREIGN KEY (StockGroupID) REFERENCES warehouse.stockgroups (StockGroupID),
    CONSTRAINT FK_Sales_SpecialDeals_StockItemID_Warehouse_StockItems FOREIGN KEY (StockItemID) REFERENCES warehouse.stockitems (StockItemID)
);

CREATE INDEX FK_Sales_SpecialDeals_StockItemID ON sales.specialdeals (StockItemID ASC);
CREATE INDEX FK_Sales_SpecialDeals_CustomerID ON sales.specialdeals (CustomerID ASC);
CREATE INDEX FK_Sales_SpecialDeals_BuyingGroupID ON sales.specialdeals (BuyingGroupID ASC);
CREATE INDEX FK_Sales_SpecialDeals_CustomerCategoryID ON sales.specialdeals (CustomerCategoryID ASC);
CREATE INDEX FK_Sales_SpecialDeals_StockGroupID ON sales.specialdeals (StockGroupID ASC);

COMMENT ON TABLE sales.specialdeals IS 'Special pricing (can include fixed prices, discount $ or discount %)';
COMMENT ON COLUMN sales.specialdeals.SpecialDealID IS 'ID (sequence based) for a special deal';
COMMENT ON COLUMN sales.specialdeals.StockItemID IS 'Stock item that the deal applies to (if NULL, then only discounts are permitted not unit prices)';
COMMENT ON COLUMN sales.specialdeals.CustomerID IS 'ID of the customer that the special pricing applies to (if NULL then all customers)';
COMMENT ON COLUMN sales.specialdeals.BuyingGroupID IS 'ID of the buying group that the special pricing applies to (optional)';
COMMENT ON COLUMN sales.specialdeals.CustomerCategoryID IS 'ID of the customer category that the special pricing applies to (optional)';
COMMENT ON COLUMN sales.specialdeals.StockGroupID IS 'ID of the stock group that the special pricing applies to (optional)';
COMMENT ON COLUMN sales.specialdeals.DealDescription IS 'Description of the special deal';
COMMENT ON COLUMN sales.specialdeals.StartDate IS 'Date that the special pricing starts from';
COMMENT ON COLUMN sales.specialdeals.EndDate IS 'Date that the special pricing ends on';
COMMENT ON COLUMN sales.specialdeals.DiscountAmount IS 'Discount per unit to be applied to sale price (optional)';
COMMENT ON COLUMN sales.specialdeals.DiscountPercentage IS 'Discount percentage per unit to be applied to sale price (optional)';
COMMENT ON COLUMN sales.specialdeals.UnitPrice IS 'Special price per unit to be applied instead of sale price (optional)';
