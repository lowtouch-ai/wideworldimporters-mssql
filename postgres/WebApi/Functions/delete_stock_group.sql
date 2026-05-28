-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteStockGroup.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.delete_stock_group(
    p_stock_group_id integer
) RETURNS void AS $$
BEGIN
    DELETE FROM warehouse.stock_groups
    WHERE StockGroupID = p_stock_group_id;
END;
$$ LANGUAGE plpgsql;
