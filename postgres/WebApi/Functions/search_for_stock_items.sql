-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/SearchForStockItems.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.search_for_stock_items(
    p_name                    varchar(100),
    p_tag                     varchar(100),
    p_min_price               numeric(18,2),
    p_max_price               numeric(18,2),
    p_stock_group_id          integer,
    p_maximum_rows_to_return  integer
) RETURNS TABLE(result jsonb) AS $$
BEGIN
    -- TODO: verify JSON shape matches original FOR JSON PATH, WITHOUT_ARRAY_WRAPPER output
    RETURN QUERY
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
        FROM webapi.stock_items AS si
        WHERE (p_name IS NULL OR si.StockItemName LIKE '%' || p_name || '%')
        AND (p_min_price IS NULL OR si.UnitPrice > p_min_price)
        AND (p_max_price IS NULL OR si.UnitPrice < p_max_price)
    )
    SELECT row_to_json(t)::jsonb
    FROM (
        SELECT
            (
                SELECT json_agg(row_to_json(v))
                FROM (
                    SELECT v.StockItemID, v.StockItemName, v.Brand, v.ColorName,
                           v.UnitPrice, v.TaxRate, v.Size, v.MarketingComments
                    FROM value v
                    WHERE (p_tag IS NULL OR EXISTS (
                        SELECT 1
                        FROM jsonb_array_elements_text((v.CustomFields::jsonb)->'Tags') AS tag
                        WHERE tag = p_tag
                    ))
                    AND (p_stock_group_id IS NULL OR EXISTS (
                        SELECT 1 FROM warehouse.stockitemstockgroups sisg
                        WHERE sisg.StockItemID = v.StockItemID
                        AND sisg.StockGroupID = p_stock_group_id
                    ))
                    LIMIT p_maximum_rows_to_return
                ) v
            ) AS value,
            (
                SELECT json_agg(row_to_json(tg))
                FROM (
                    SELECT tag AS "Tag", COUNT(*) AS "Items"
                    FROM value v
                    CROSS JOIN LATERAL jsonb_array_elements_text((v.CustomFields::jsonb)->'Tags') AS tag
                    GROUP BY tag
                ) tg
            ) AS tags
    ) t;
END;
$$ LANGUAGE plpgsql;
