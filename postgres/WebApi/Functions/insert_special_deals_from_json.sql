CREATE SCHEMA IF NOT EXISTS webapi;

-- Exactly one of DiscountAmount, DiscountPercentage, UnitPrice must be non-null (DB check constraint).
CREATE OR REPLACE FUNCTION webapi.insert_special_deals_from_json(
    p_special_deals text,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    INSERT INTO sales.specialdeals (
        StockItemID, CustomerID, BuyingGroupID, CustomerCategoryID, StockGroupID,
        DealDescription, StartDate, EndDate,
        DiscountAmount, DiscountPercentage, UnitPrice, LastEditedBy
    )
    SELECT
        x."StockItemID", x."CustomerID", x."BuyingGroupID",
        x."CustomerCategoryID", x."StockGroupID",
        x."DealDescription", x."StartDate", x."EndDate",
        x."DiscountAmount", x."DiscountPercentage", x."UnitPrice",
        p_user_id
    FROM jsonb_to_recordset(
        CASE WHEN jsonb_typeof(p_special_deals::jsonb) = 'array'
             THEN p_special_deals::jsonb
             ELSE jsonb_build_array(p_special_deals::jsonb) END
    ) AS x(
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
    );
END;
$$ LANGUAGE plpgsql;
