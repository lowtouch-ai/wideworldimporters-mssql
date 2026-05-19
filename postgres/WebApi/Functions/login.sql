-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/Login.sql
-- Note: HASHBYTES / password check commented out in original; preserved as comment here.
-- JSON_VALUE(CustomFields,'$.PrimarySalesTerritory') → CustomFields->>'PrimarySalesTerritory'
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.login(
    p_logon_name varchar(256),
    p_password varchar(256)
) RETURNS TABLE (
    PersonID integer,
    PreferredName varchar(50),
    IsSalesperson boolean,
    IsEmployee boolean,
    Territory text
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.PersonID,
        p.PreferredName,
        p.IsSalesperson,
        p.IsEmployee,
        CASE WHEN p.CustomFields IS NOT NULL THEN (p.CustomFields::jsonb)->>'PrimarySalesTerritory' ELSE NULL END AS Territory
    FROM application.people p
    WHERE p.IsPermittedToLogon = TRUE
      AND p.LogonName = p_logon_name;
      -- AND HashedPassword = digest(p_password, 'sha256')  -- requires pgcrypto extension
END;
$$ LANGUAGE plpgsql;
