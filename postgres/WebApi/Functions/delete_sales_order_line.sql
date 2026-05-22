CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.delete_sales_order_line(
    p_sales_order_line_id integer
) RETURNS void AS $$
BEGIN
    DELETE FROM sales.orderlines
    WHERE OrderLineID = p_sales_order_line_id;
END;
$$ LANGUAGE plpgsql;
