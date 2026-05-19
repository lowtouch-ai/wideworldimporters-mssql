-- Converted from: wwi-ssdt/wwi-ssdt/Application/Functions/DetermineCustomerAccess.sql
-- NOTE: pg_has_role() throws if the role does not exist (unlike IS_ROLEMEMBER which returns NULL).
--       Each check is wrapped in a sub-block with EXCEPTION WHEN undefined_object so missing roles
--       are treated as non-membership, matching MSSQL behaviour.
-- NOTE: SESSION_CONTEXT(N'SalesTerritory') → current_setting('app.SalesTerritory', true).
--       Set via: SET LOCAL "app.SalesTerritory" = '<territory>' before calling.
CREATE SCHEMA IF NOT EXISTS application;

CREATE OR REPLACE FUNCTION application.determine_customer_access(
    p_city_id integer
) RETURNS TABLE(AccessResult integer) AS $$
DECLARE
    _is_owner            boolean := false;
    _territory           varchar(50);
    _is_territory_member boolean := false;
BEGIN
    BEGIN
        _is_owner := pg_has_role(current_user, 'db_owner', 'MEMBER');
    EXCEPTION WHEN undefined_object THEN
        _is_owner := false;
    END;

    IF _is_owner THEN
        RETURN QUERY SELECT 1;
        RETURN;
    END IF;

    SELECT sp.salesterritory INTO _territory
    FROM application.cities AS c
    INNER JOIN application.state_provinces AS sp
        ON c.stateprovinceid = sp.stateprovinceid
    WHERE c.cityid = p_city_id;

    IF _territory IS NOT NULL THEN
        BEGIN
            _is_territory_member := pg_has_role(current_user, _territory || ' Sales', 'MEMBER');
        EXCEPTION WHEN undefined_object THEN
            _is_territory_member := false;
        END;
    END IF;

    IF _is_territory_member THEN
        RETURN QUERY SELECT 1;
        RETURN;
    END IF;

    IF (session_user = 'Website' OR session_user = 'WebApi')
       AND EXISTS (
           SELECT 1
           FROM application.cities AS c
           INNER JOIN application.state_provinces AS sp
               ON c.stateprovinceid = sp.stateprovinceid
           WHERE c.cityid = p_city_id
             AND sp.salesterritory = current_setting('app.SalesTerritory', true)
       ) THEN
        RETURN QUERY SELECT 1;
    END IF;
END;
$$ LANGUAGE plpgsql;
