-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateSupplierCategoryFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_supplier_category_from_json(
    p_supplier_category text,
    p_supplier_category_id integer,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    UPDATE purchasing.suppliercategories SET
        SupplierCategoryName = json.SupplierCategoryName,
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_supplier_category::jsonb) AS json(SupplierCategoryName varchar(50))
    WHERE SupplierCategoryID = p_supplier_category_id;
END;
$$ LANGUAGE plpgsql;
