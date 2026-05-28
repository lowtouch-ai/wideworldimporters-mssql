CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.delete_purchase_order_line(
    p_purchase_order_line_id integer
) RETURNS void AS $$
BEGIN
    DELETE FROM purchasing.purchaseorderlines
    WHERE PurchaseOrderLineID = p_purchase_order_line_id;
END;
$$ LANGUAGE plpgsql;
