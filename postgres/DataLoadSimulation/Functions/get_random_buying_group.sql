-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomBuyingGroup.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.get_random_buying_group(
) RETURNS TABLE(buying_group_id integer, buying_group_name varchar(50)) AS $$
BEGIN
    RETURN QUERY
    SELECT bg."BuyingGroupID", bg."BuyingGroupName"::varchar(50)
    FROM sales.buyinggroups bg
    WHERE bg."ValidTo" = '9999-12-31 23:59:59.999999'
      AND bg."BuyingGroupID" > 1
    ORDER BY random()
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;
