-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteBuyingGroup.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.delete_buying_group(
    p_buying_group_id integer
) RETURNS void AS $$
BEGIN
    DELETE FROM sales.buying_groups
    WHERE BuyingGroupID = p_buying_group_id;
END;
$$ LANGUAGE plpgsql;
