-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateBuyingGroupFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_buying_group_from_json(
    p_buying_group text,
    p_buying_group_id integer,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    UPDATE sales.buyinggroups SET
        BuyingGroupName = json.BuyingGroupName,
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_buying_group::jsonb) AS json(BuyingGroupName varchar(50))
    WHERE BuyingGroupID = p_buying_group_id;
END;
$$ LANGUAGE plpgsql;
