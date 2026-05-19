-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertBuyingGroupsFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.insert_buying_groups_from_json(
    p_buying_groups text,
    p_user_id       integer
) RETURNS TABLE(buyinggroupid integer) AS $$
BEGIN
    RETURN QUERY
    INSERT INTO sales.buying_groups(buyinggroupname, lasteditedby)
    SELECT x."BuyingGroupName", p_user_id
    FROM jsonb_to_recordset(p_buying_groups::jsonb) AS x("BuyingGroupName" varchar(50))
    RETURNING buying_groups.buyinggroupid;
END;
$$ LANGUAGE plpgsql;
