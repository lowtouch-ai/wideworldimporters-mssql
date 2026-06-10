-- Converted from: wwi-ssdt/wwi-ssdt/Application/Functions/DetermineCustomerAccess.sql
CREATE SCHEMA IF NOT EXISTS application;

CREATE OR REPLACE FUNCTION application.determine_customer_access(
    p_city_id integer
) RETURNS TABLE(AccessResult integer) AS $$
DECLARE
    v_sales_territory varchar(50);
BEGIN
    -- Resolve the SalesTerritory for the given CityID once, used in two places below
    SELECT sp.SalesTerritory
    INTO v_sales_territory
    FROM application.cities AS c
    INNER JOIN application.stateprovinces AS sp
        ON c.StateProvinceID = sp.StateProvinceID
    WHERE c.CityID = p_city_id;

    RETURN QUERY
    SELECT 1 AS AccessResult
    WHERE
        -- db_owner check: pre-guard against non-existent role (pg_has_role throws unlike IS_ROLEMEMBER)
        (EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'db_owner')
         AND pg_has_role(current_user, 'db_owner', 'member'))

        -- sales territory role check: same pre-guard pattern
        OR (v_sales_territory IS NOT NULL
            AND EXISTS (SELECT 1 FROM pg_roles WHERE rolname = v_sales_territory || ' Sales')
            AND pg_has_role(current_user, v_sales_territory || ' Sales', 'member'))

        -- Website / WebApi user with matching session SalesTerritory
        -- SESSION_CONTEXT(N'SalesTerritory') → current_setting('app.SalesTerritory', true)
        -- ORIGINAL_LOGIN() → current_user (PostgreSQL has no impersonation distinction)
        OR (
            (current_user = 'Website' OR current_user = 'WebApi')
            AND v_sales_territory IS NOT NULL
            AND v_sales_territory = current_setting('app.SalesTerritory', true)
        );
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;
