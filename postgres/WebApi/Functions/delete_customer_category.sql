-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteCustomerCategory.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.delete_customer_category(
    p_customer_category_id integer
) RETURNS void AS $$
BEGIN
    DELETE FROM sales.customercategories
    WHERE CustomerCategoryID = p_customer_category_id;
END;
$$ LANGUAGE plpgsql;
