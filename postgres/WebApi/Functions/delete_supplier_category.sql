-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteSupplierCategory.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.delete_supplier_category(
    p_supplier_category_id integer
) RETURNS void AS $$
BEGIN
    DELETE FROM purchasing.supplier_categories
    WHERE SupplierCategoryID = p_supplier_category_id;
END;
$$ LANGUAGE plpgsql;
