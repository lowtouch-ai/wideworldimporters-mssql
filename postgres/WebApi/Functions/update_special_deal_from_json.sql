-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateSpecialDealFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_special_deal_from_json(
    p_special_deal text,
    p_special_deal_id integer,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    UPDATE sales.specialdeals SET
        StockItemID = json.StockItemID,
        CustomerID = json.CustomerID,
        BuyingGroupID = json.BuyingGroupID,
        CustomerCategoryID = json.CustomerCategoryID,
        StockGroupID = json.StockGroupID,
        DealDescription = COALESCE(json.DealDescription, sales.specialdeals.DealDescription),
        StartDate = COALESCE(json.StartDate, sales.specialdeals.StartDate),
        EndDate = COALESCE(json.EndDate, sales.specialdeals.EndDate),
        DiscountAmount = json.DiscountAmount,
        DiscountPercentage = json.DiscountPercentage,
        UnitPrice = json.UnitPrice,
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_special_deal::jsonb) AS json(
        StockItemID integer,
        CustomerID integer,
        BuyingGroupID integer,
        CustomerCategoryID integer,
        StockGroupID integer,
        DealDescription varchar(30),
        StartDate date,
        EndDate date,
        DiscountAmount numeric(18,2),
        DiscountPercentage numeric(18,3),
        UnitPrice numeric(18,2)
    )
    WHERE SpecialDealID = p_special_deal_id;
END;
$$ LANGUAGE plpgsql;
