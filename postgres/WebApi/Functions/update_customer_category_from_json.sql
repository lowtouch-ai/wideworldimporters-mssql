-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateCustomerCategoryFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_customer_category_from_json(
    p_customer_category    text,
    p_customer_category_id integer,
    p_user_id              integer
) RETURNS void AS $$
BEGIN
    UPDATE sales.customer_categories
    SET customercategoryname = x."CustomerCategoryName",
        lasteditedby         = p_user_id
    FROM jsonb_to_record(p_customer_category::jsonb) AS x("CustomerCategoryName" varchar(50))
    WHERE customer_categories.customercategoryid = p_customer_category_id;
END;
$$ LANGUAGE plpgsql;
