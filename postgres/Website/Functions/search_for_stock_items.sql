-- Converted from: wwi-ssdt/wwi-ssdt/Website/Stored Procedures/SearchForStockItems.sql
CREATE SCHEMA IF NOT EXISTS website;

CREATE OR REPLACE FUNCTION website.search_for_stock_items(
    p_search_text varchar(1000),
    p_maximum_rows_to_return integer
) RETURNS jsonb AS $$
BEGIN
    -- TODO: verify JSON shape matches original FOR JSON AUTO, ROOT(N'StockItems')
    RETURN (
        SELECT json_build_object('StockItems', COALESCE(json_agg(row_to_json(t)), '[]'::json))
        FROM (
            SELECT si.stockitemid   AS "StockItemID",
                   si.stockitemname AS "StockItemName"
            FROM warehouse.stockitems AS si
            WHERE si.searchdetails LIKE '%' || p_search_text || '%'
            ORDER BY si.stockitemname
            LIMIT p_maximum_rows_to_return
        ) t
    );
END;
$$ LANGUAGE plpgsql;
