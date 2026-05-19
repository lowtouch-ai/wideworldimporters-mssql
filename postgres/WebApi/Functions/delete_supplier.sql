-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteSupplier.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.delete_supplier(
    p_supplier_id integer
) RETURNS void AS $$
BEGIN
    DELETE FROM purchasing.suppliers
    WHERE SupplierID = p_supplier_id;
END;
$$ LANGUAGE plpgsql;
