-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteStockItem.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.delete_stock_item(
    p_stock_item_id integer
) RETURNS void AS $$
BEGIN
    DELETE FROM warehouse.stockitems
    WHERE StockItemID = p_stock_item_id;
END;
$$ LANGUAGE plpgsql;
