-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomCustomerCategory.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.get_random_customer_category(
) RETURNS integer AS $$
DECLARE
    v_id integer;
BEGIN
    SELECT "CustomerCategoryID" INTO v_id
    FROM sales.customercategories
    WHERE "CustomerCategoryID" > 0
      AND "CustomerCategoryName" <> 'Corporate'
    ORDER BY random()
    LIMIT 1;

    RETURN v_id;
END;
$$ LANGUAGE plpgsql;
