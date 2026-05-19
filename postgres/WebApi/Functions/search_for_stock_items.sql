-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/SearchForStockItems.sql
-- Note: Original returns a single JSON blob (FOR JSON PATH, WITHOUT_ARRAY_WRAPPER).
-- Converted to return that same JSON structure as a text value via PostgreSQL json_agg / row_to_json.
-- The source SP reads from WebApi.StockItems (a view) — mapped to webapi.stockitems.
-- OPENJSON over CustomFields $.Tags → jsonb_array_elements_text on CustomFields->'Tags'.
-- Warehouse.StockItemStockGroups → warehouse.stockitemstockgroups.
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.search_for_stock_items(
    p_name varchar(100),
    p_tag varchar(100),
    p_min_price numeric(18,2),
    p_max_price numeric(18,2),
    p_stock_group_id integer,
    p_maximum_rows_to_return integer
) RETURNS text AS $$
DECLARE
    _result text;
BEGIN
    WITH value AS (
        SELECT
            si.StockItemID,
            si.StockItemName,
            si.Brand,
            si.ColorName,
            si.UnitPrice,
            si.TaxRate,
            si.Size,
            si.MarketingComments,
            si.CustomFields
        FROM webapi.stockitems AS si
        WHERE (p_name IS NULL OR si.StockItemName ILIKE ('%' || p_name || '%'))
          AND (p_min_price IS NULL OR si.UnitPrice > p_min_price)
          AND (p_max_price IS NULL OR si.UnitPrice < p_max_price)
    ),
    filtered AS (
        SELECT v.*
        FROM value v
        WHERE (p_tag IS NULL OR EXISTS (
            SELECT 1
            FROM jsonb_array_elements_text(v.CustomFields->'Tags') AS t(tag)
            WHERE t.tag = p_tag
        ))
          AND (p_stock_group_id IS NULL OR EXISTS (
            SELECT 1
            FROM warehouse.stockitemstockgroups sisg
            WHERE sisg.StockItemID = v.StockItemID
              AND sisg.StockGroupID = p_stock_group_id
        ))
    ),
    tag_counts AS (
        SELECT t.tag, COUNT(*) AS Items
        FROM value v
        CROSS JOIN jsonb_array_elements_text(v.CustomFields->'Tags') AS t(tag)
        GROUP BY t.tag
    )
    SELECT json_build_object(
        'value', (
            SELECT json_agg(row_to_json(r))
            FROM (
                SELECT StockItemID, StockItemName, Brand, ColorName, UnitPrice, TaxRate, Size, MarketingComments
                FROM filtered
                LIMIT p_maximum_rows_to_return
            ) r
        ),
        'tags', (SELECT json_agg(row_to_json(tc)) FROM tag_counts tc)
    )::text INTO _result;

    RETURN _result;
END;
$$ LANGUAGE plpgsql;
