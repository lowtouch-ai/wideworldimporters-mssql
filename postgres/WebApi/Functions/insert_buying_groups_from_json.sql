-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertBuyingGroupsFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.insert_buying_groups_from_json(
    p_buying_groups text,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    INSERT INTO sales.buyinggroups (BuyingGroupName, LastEditedBy)
    SELECT x.BuyingGroupName, p_user_id
    FROM jsonb_to_recordset(p_buying_groups::jsonb) AS x(BuyingGroupName varchar(50));
END;
$$ LANGUAGE plpgsql;
