CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.delete_purchase_order(
    p_purchase_order_id integer
) RETURNS void AS $$
BEGIN
    DELETE FROM purchasing.purchaseorders
    WHERE PurchaseOrderID = p_purchase_order_id;
END;
$$ LANGUAGE plpgsql;
