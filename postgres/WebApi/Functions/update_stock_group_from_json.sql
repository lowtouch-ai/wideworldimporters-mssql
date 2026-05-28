-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateStockGroupFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_stock_group_from_json(
    p_stock_group text,
    p_stock_group_id integer,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    UPDATE warehouse.stockgroups SET
        "StockGroupName" = json.stock_group_name,
        "LastEditedBy" = p_user_id
    FROM jsonb_to_recordset(p_stock_group::jsonb) AS json(
        stock_group_name varchar(50)
    )
    WHERE warehouse.stockgroups."StockGroupID" = p_stock_group_id;
END;
$$ LANGUAGE plpgsql;
