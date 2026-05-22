CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.delete_sales_order(
    p_sales_order_id integer
) RETURNS void AS $$
BEGIN
    DELETE FROM sales.orders
    WHERE OrderID = p_sales_order_id;
END;
$$ LANGUAGE plpgsql;
