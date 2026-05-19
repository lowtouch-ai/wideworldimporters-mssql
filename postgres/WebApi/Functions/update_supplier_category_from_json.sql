-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateSupplierCategoryFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_supplier_category_from_json(
    p_supplier_category text,
    p_supplier_category_id integer,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    UPDATE purchasing.suppliercategories SET
        "SupplierCategoryName" = json.supplier_category_name,
        "LastEditedBy" = p_user_id
    FROM jsonb_to_recordset(p_supplier_category::jsonb) AS json(
        supplier_category_name varchar(50)
    )
    WHERE purchasing.suppliercategories."SupplierCategoryID" = p_supplier_category_id;
END;
$$ LANGUAGE plpgsql;
