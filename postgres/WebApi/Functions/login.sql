-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/Login.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.login(
    p_logon_name varchar(256),
    p_password   varchar(256)
) RETURNS TABLE(
    PersonID      integer,
    PreferredName varchar(50),
    IsSalesperson boolean,
    IsEmployee    boolean,
    Territory     text
) AS $$
BEGIN
    -- NOTE: password check (HASHBYTES SHA2_256) was commented out in the original SP;
    -- p_password is accepted as a parameter but not validated here
    RETURN QUERY
    SELECT
        p.PersonID,
        p.PreferredName,
        p.IsSalesperson,
        p.IsEmployee,
        (p.CustomFields::jsonb)->>'PrimarySalesTerritory' AS Territory
    FROM application.people AS p
    WHERE p.IsPermittedToLogon = TRUE
    AND p.LogonName = p_logon_name;
END;
$$ LANGUAGE plpgsql;
