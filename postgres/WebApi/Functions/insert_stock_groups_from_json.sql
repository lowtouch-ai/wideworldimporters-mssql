-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertStockGroupsFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.insert_stock_groups_from_json(
    p_stock_groups text,
    p_user_id      integer
) RETURNS TABLE(stockgroupid integer) AS $$
BEGIN
    RETURN QUERY
    INSERT INTO warehouse.stock_groups(stockgroupname, lasteditedby)
    SELECT x."StockGroupName", p_user_id
    FROM jsonb_to_recordset(p_stock_groups::jsonb) AS x("StockGroupName" varchar(50))
    RETURNING stock_groups.stockgroupid;
END;
$$ LANGUAGE plpgsql;
