-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateSpecialDealFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_special_deal_from_json(
    p_special_deal    text,
    p_special_deal_id integer,
    p_user_id         integer
) RETURNS void AS $$
BEGIN
    -- StockItemID, CustomerID, BuyingGroupID, CustomerCategoryID, StockGroupID,
    -- DiscountAmount, DiscountPercentage, UnitPrice: direct (allow NULL)
    UPDATE sales.specialdeals
    SET stockitemid         = x."StockItemID",
        customerid          = x."CustomerID",
        buyinggroupid       = x."BuyingGroupID",
        customercategoryid  = x."CustomerCategoryID",
        stockgroupid        = x."StockGroupID",
        dealdescription     = COALESCE(x."DealDescription", specialdeals.dealdescription),
        startdate           = COALESCE(x."StartDate",        specialdeals.startdate),
        enddate             = COALESCE(x."EndDate",          specialdeals.enddate),
        discountamount      = x."DiscountAmount",
        discountpercentage  = x."DiscountPercentage",
        unitprice           = x."UnitPrice",
        lasteditedby        = p_user_id
    FROM jsonb_to_record(p_special_deal::jsonb) AS x(
        "StockItemID"        integer,
        "CustomerID"         integer,
        "BuyingGroupID"      integer,
        "CustomerCategoryID" integer,
        "StockGroupID"       integer,
        "DealDescription"    varchar(30),
        "StartDate"          date,
        "EndDate"            date,
        "DiscountAmount"     numeric(18,2),
        "DiscountPercentage" numeric(18,3),
        "UnitPrice"          numeric(18,2)
    )
    WHERE specialdeals.specialdealid = p_special_deal_id;
END;
$$ LANGUAGE plpgsql;
