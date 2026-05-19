-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdatePurchaseOrderFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_purchase_order_from_json(
    p_purchase_order    text,
    p_purchase_order_id integer,
    p_user_id           integer
) RETURNS void AS $$
BEGIN
    -- ExpectedDeliveryDate, SupplierReference: direct (allow NULL)
    UPDATE purchasing.purchaseorders
    SET supplierid            = COALESCE(x."SupplierID",         purchaseorders.supplierid),
        orderdate             = COALESCE(x."OrderDate",          purchaseorders.orderdate),
        deliverymethodid      = COALESCE(x."DeliveryMethodID",   purchaseorders.deliverymethodid),
        contactpersonid       = COALESCE(x."ContactPersonID",    purchaseorders.contactpersonid),
        expecteddeliverydate  = x."ExpectedDeliveryDate",
        supplierreference     = x."SupplierReference",
        isorderfinalized      = COALESCE(x."IsOrderFinalized",   purchaseorders.isorderfinalized)
    FROM jsonb_to_record(p_purchase_order::jsonb) AS x(
        "SupplierID"           integer,
        "OrderDate"            date,
        "DeliveryMethodID"     integer,
        "ContactPersonID"      integer,
        "ExpectedDeliveryDate" date,
        "SupplierReference"    varchar(20),
        "IsOrderFinalized"     boolean
    )
    WHERE purchaseorders.purchaseorderid = p_purchase_order_id;
END;
$$ LANGUAGE plpgsql;
