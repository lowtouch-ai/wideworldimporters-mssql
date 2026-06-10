CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_purchase_order_line_from_json(
    p_purchase_order_line text,
    p_purchase_order_line_id integer,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    UPDATE purchasing.purchaseorderlines SET
        PurchaseOrderID           = COALESCE(json."PurchaseOrderID", purchasing.purchaseorderlines.PurchaseOrderID),
        StockItemID               = COALESCE(json."StockItemID", purchasing.purchaseorderlines.StockItemID),
        OrderedOuters             = COALESCE(json."OrderedOuters", purchasing.purchaseorderlines.OrderedOuters),
        Description               = COALESCE(json."Description", purchasing.purchaseorderlines.Description),
        ReceivedOuters            = COALESCE(json."ReceivedOuters", purchasing.purchaseorderlines.ReceivedOuters),
        PackageTypeID             = COALESCE(json."PackageTypeID", purchasing.purchaseorderlines.PackageTypeID),
        ExpectedUnitPricePerOuter = COALESCE(json."ExpectedUnitPricePerOuter", purchasing.purchaseorderlines.ExpectedUnitPricePerOuter),
        LastReceiptDate           = json."LastReceiptDate",
        IsOrderLineFinalized      = COALESCE(json."IsOrderLineFinalized", purchasing.purchaseorderlines.IsOrderLineFinalized),
        LastEditedBy              = p_user_id
    FROM jsonb_to_record(p_purchase_order_line::jsonb) AS json(
        "PurchaseOrderID"           integer,
        "StockItemID"               integer,
        "OrderedOuters"             integer,
        "Description"               varchar(100),
        "ReceivedOuters"            integer,
        "PackageTypeID"             integer,
        "ExpectedUnitPricePerOuter" numeric(18,2),
        "LastReceiptDate"           date,
        "IsOrderLineFinalized"      boolean
    )
    WHERE PurchaseOrderLineID = p_purchase_order_line_id;
END;
$$ LANGUAGE plpgsql;
