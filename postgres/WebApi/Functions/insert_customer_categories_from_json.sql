-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertCustomerCategoriesFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.insert_customer_categories_from_json(
    p_customer_categories text,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    INSERT INTO sales.customercategories (CustomerCategoryName, LastEditedBy)
    SELECT x.CustomerCategoryName, p_user_id
    FROM jsonb_to_recordset(p_customer_categories::jsonb) AS x(CustomerCategoryName varchar(50));
END;
$$ LANGUAGE plpgsql;
