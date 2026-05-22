CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.insert_sales_order_lines_from_json(
    p_sales_order_lines text,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    INSERT INTO sales.orderlines (
        OrderID, StockItemID, Description, PackageTypeID,
        Quantity, UnitPrice, TaxRate, PickedQuantity, LastEditedBy
    )
    SELECT
        x."OrderID", x."StockItemID", x."Description", x."PackageTypeID",
        x."Quantity", x."UnitPrice", x."TaxRate",
        COALESCE(x."PickedQuantity", 0), p_user_id
    FROM jsonb_to_recordset(
        CASE WHEN jsonb_typeof(p_sales_order_lines::jsonb) = 'array'
             THEN p_sales_order_lines::jsonb
             ELSE jsonb_build_array(p_sales_order_lines::jsonb) END
    ) AS x(
        "OrderID"       integer,
        "StockItemID"   integer,
        "Description"   varchar(100),
        "PackageTypeID" integer,
        "Quantity"      integer,
        "UnitPrice"     numeric(18,2),
        "TaxRate"       numeric(18,3),
        "PickedQuantity" integer
    );
END;
$$ LANGUAGE plpgsql;
