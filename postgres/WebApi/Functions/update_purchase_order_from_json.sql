-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdatePurchaseOrderFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_purchase_order_from_json(
    p_purchase_order text,
    p_purchase_order_id integer,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    UPDATE purchasing.purchaseorders SET
        SupplierID = COALESCE(json.SupplierID, purchasing.purchaseorders.SupplierID),
        OrderDate = COALESCE(json.OrderDate, purchasing.purchaseorders.OrderDate),
        DeliveryMethodID = COALESCE(json.DeliveryMethodID, purchasing.purchaseorders.DeliveryMethodID),
        ContactPersonID = COALESCE(json.ContactPersonID, purchasing.purchaseorders.ContactPersonID),
        ExpectedDeliveryDate = json.ExpectedDeliveryDate,
        SupplierReference = json.SupplierReference,
        IsOrderFinalized = COALESCE(json.IsOrderFinalized, purchasing.purchaseorders.IsOrderFinalized)
    FROM jsonb_to_record(p_purchase_order::jsonb) AS json(
        SupplierID integer,
        OrderDate date,
        DeliveryMethodID integer,
        ContactPersonID integer,
        ExpectedDeliveryDate date,
        SupplierReference varchar(20),
        IsOrderFinalized boolean
    )
    WHERE PurchaseOrderID = p_purchase_order_id;
END;
$$ LANGUAGE plpgsql;
