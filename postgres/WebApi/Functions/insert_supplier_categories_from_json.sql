-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertSupplierCategoriesFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.insert_supplier_categories_from_json(
    p_supplier_categories text,
    p_user_id             integer
) RETURNS TABLE(suppliercategoryid integer) AS $$
BEGIN
    RETURN QUERY
    INSERT INTO purchasing.supplier_categories(suppliercategoryname, lasteditedby)
    SELECT x."SupplierCategoryName", p_user_id
    FROM jsonb_to_recordset(p_supplier_categories::jsonb) AS x("SupplierCategoryName" varchar(50))
    RETURNING supplier_categories.suppliercategoryid;
END;
$$ LANGUAGE plpgsql;
