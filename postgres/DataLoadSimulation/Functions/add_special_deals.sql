-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/AddSpecialDeals.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.add_special_deals(
    p_current_date_time timestamp,
    p_starting_when     timestamp,
    p_end_of_time       timestamp,
    p_is_silent_mode    boolean
) RETURNS void AS $$
BEGIN
    IF CAST(p_current_date_time AS date) = '2021-12-31' THEN

        INSERT INTO sales.specialdeals
            ("StockItemID", "CustomerID", "BuyingGroupID", "CustomerCategoryID", "StockGroupID",
             "DealDescription", "StartDate", "EndDate", "DiscountAmount", "DiscountPercentage",
             "UnitPrice", "LastEditedBy", "LastEditedWhen")
        VALUES
            (NULL, NULL, (SELECT "BuyingGroupID" FROM sales.buyinggroups WHERE "BuyingGroupName" = 'Wingtip Toys'),
             NULL, (SELECT "StockGroupID" FROM warehouse.stockgroups WHERE "StockGroupName" = 'USB Novelties'),
             '10% 1st qtr USB Wingtip', '2022-01-01', '2022-03-31', NULL, 10, NULL,
             2, p_starting_when);

        INSERT INTO sales.specialdeals
            ("StockItemID", "CustomerID", "BuyingGroupID", "CustomerCategoryID", "StockGroupID",
             "DealDescription", "StartDate", "EndDate", "DiscountAmount", "DiscountPercentage",
             "UnitPrice", "LastEditedBy", "LastEditedWhen")
        VALUES
            (NULL, NULL, (SELECT "BuyingGroupID" FROM sales.buyinggroups WHERE "BuyingGroupName" = 'Tailspin Toys'),
             NULL, (SELECT "StockGroupID" FROM warehouse.stockgroups WHERE "StockGroupName" = 'USB Novelties'),
             '15% 2nd qtr USB Tailspin', '2022-04-01', '2022-06-30', NULL, 15, NULL,
             2, p_starting_when);

    END IF;
END;
$$ LANGUAGE plpgsql;
