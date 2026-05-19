-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateBuyingGroupFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_buying_group_from_json(
    p_buying_group    text,
    p_buying_group_id integer,
    p_user_id         integer
) RETURNS void AS $$
BEGIN
    UPDATE sales.buying_groups
    SET buyinggroupname = x."BuyingGroupName",
        lasteditedby    = p_user_id
    FROM jsonb_to_record(p_buying_group::jsonb) AS x("BuyingGroupName" varchar(50))
    WHERE buying_groups.buyinggroupid = p_buying_group_id;
END;
$$ LANGUAGE plpgsql;
