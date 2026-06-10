-- Converted from: wwi-ssdt/wwi-ssdt/Website/Stored Procedures/SearchForStockItemsByTags.sql
CREATE SCHEMA IF NOT EXISTS website;

-- TODO: FOR JSON AUTO, ROOT('StockItems') has no direct PostgreSQL equivalent.
-- This function returns a result set. Callers can wrap with json_agg(row_to_json(t)).

CREATE OR REPLACE FUNCTION website.search_for_stock_items_by_tags(
    p_SearchText varchar(1000),
    p_MaximumRowsToReturn integer
) RETURNS TABLE (
    StockItemID integer,
    StockItemName varchar(100)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        si.StockItemID,
        si.StockItemName
    FROM warehouse.stockitems AS si
    WHERE si.Tags ILIKE '%' || p_SearchText || '%'
    ORDER BY si.StockItemName
    LIMIT p_MaximumRowsToReturn;
END;
$$ LANGUAGE plpgsql;
