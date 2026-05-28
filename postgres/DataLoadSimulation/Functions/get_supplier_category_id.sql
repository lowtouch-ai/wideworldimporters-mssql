-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Functions/GetSupplierCategoryID.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.get_supplier_category_id(
    p_supplier_category_name varchar(50)
) RETURNS integer AS $$
DECLARE
    _sup_cat_id integer;
BEGIN
    SELECT SupplierCategoryID INTO _sup_cat_id
    FROM purchasing.supplier_categories
    WHERE SupplierCategoryName = p_supplier_category_name
      AND ValidTo = '9999-12-31 23:59:59.999999'
    LIMIT 1;

    RETURN _sup_cat_id;
END;
$$ LANGUAGE plpgsql;
