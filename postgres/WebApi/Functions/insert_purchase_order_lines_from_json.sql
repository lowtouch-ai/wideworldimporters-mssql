CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.insert_purchase_order_lines_from_json(
    p_purchase_order_lines text,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    INSERT INTO purchasing.purchaseorderlines (
        PurchaseOrderID, StockItemID, OrderedOuters, Description, ReceivedOuters,
        PackageTypeID, ExpectedUnitPricePerOuter, LastReceiptDate,
        IsOrderLineFinalized, LastEditedBy
    )
    SELECT
        x."PurchaseOrderID", x."StockItemID", x."OrderedOuters", x."Description",
        COALESCE(x."ReceivedOuters", 0), x."PackageTypeID",
        x."ExpectedUnitPricePerOuter", x."LastReceiptDate",
        COALESCE(x."IsOrderLineFinalized", false), p_user_id
    FROM jsonb_to_recordset(
        CASE WHEN jsonb_typeof(p_purchase_order_lines::jsonb) = 'array'
             THEN p_purchase_order_lines::jsonb
             ELSE jsonb_build_array(p_purchase_order_lines::jsonb) END
    ) AS x(
        "PurchaseOrderID"           integer,
        "StockItemID"               integer,
        "OrderedOuters"             integer,
        "Description"               varchar(100),
        "ReceivedOuters"            integer,
        "PackageTypeID"             integer,
        "ExpectedUnitPricePerOuter" numeric(18,2),
        "LastReceiptDate"           date,
        "IsOrderLineFinalized"      boolean
    );
END;
$$ LANGUAGE plpgsql;
