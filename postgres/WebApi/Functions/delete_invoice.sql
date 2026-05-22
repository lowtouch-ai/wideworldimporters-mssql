CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.delete_invoice(
    p_invoice_id integer
) RETURNS void AS $$
BEGIN
    DELETE FROM sales.invoices
    WHERE InvoiceID = p_invoice_id;
END;
$$ LANGUAGE plpgsql;
