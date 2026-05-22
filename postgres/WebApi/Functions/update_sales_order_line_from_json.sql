CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_sales_order_line_from_json(
    p_sales_order_line text,
    p_sales_order_line_id integer,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    UPDATE sales.orderlines SET
        OrderID               = COALESCE(json."OrderID",        sales.orderlines.OrderID),
        StockItemID           = COALESCE(json."StockItemID",    sales.orderlines.StockItemID),
        Description           = COALESCE(json."Description",    sales.orderlines.Description),
        PackageTypeID         = COALESCE(json."PackageTypeID",  sales.orderlines.PackageTypeID),
        Quantity              = COALESCE(json."Quantity",        sales.orderlines.Quantity),
        UnitPrice             = json."UnitPrice",
        TaxRate               = COALESCE(json."TaxRate",         sales.orderlines.TaxRate),
        PickedQuantity        = COALESCE(json."PickedQuantity",  sales.orderlines.PickedQuantity),
        PickingCompletedWhen  = json."PickingCompletedWhen",
        LastEditedBy          = p_user_id
    FROM jsonb_to_record(p_sales_order_line::jsonb) AS json(
        "OrderID"             integer,
        "StockItemID"         integer,
        "Description"         varchar(100),
        "PackageTypeID"       integer,
        "Quantity"            integer,
        "UnitPrice"           numeric(18,2),
        "TaxRate"             numeric(18,3),
        "PickedQuantity"      integer,
        "PickingCompletedWhen" timestamp
    )
    WHERE OrderLineID = p_sales_order_line_id;
END;
$$ LANGUAGE plpgsql;
