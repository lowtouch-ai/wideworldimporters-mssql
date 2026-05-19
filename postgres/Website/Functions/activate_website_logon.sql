-- Converted from: wwi-ssdt/wwi-ssdt/Website/Stored Procedures/ActivateWebsiteLogon.sql
CREATE SCHEMA IF NOT EXISTS website;

CREATE OR REPLACE FUNCTION website.activate_website_logon(
    p_PersonID integer,
    p_LogonName varchar(50),
    p_InitialPassword varchar(40)
) RETURNS void AS $$
DECLARE
    _rowcount integer;
BEGIN
    UPDATE application.people
    SET IsPermittedToLogon = true,
        LogonName = p_LogonName,
        -- NOTE: HASHBYTES('SHA2_256', ...) has no direct PostgreSQL equivalent.
        -- TODO: Replace with pgcrypto: encode(digest(p_InitialPassword || FullName, 'sha256'), 'hex')
        -- Requires: CREATE EXTENSION IF NOT EXISTS pgcrypto;
        HashedPassword = encode(digest(p_InitialPassword || FullName, 'sha256'), 'hex'),
        UserPreferences = (SELECT UserPreferences FROM application.people WHERE PersonID = 1)
    WHERE PersonID = p_PersonID
    AND PersonID <> 1
    AND IsPermittedToLogon = false;

    GET DIAGNOSTICS _rowcount = ROW_COUNT;

    IF _rowcount = 0 THEN
        RAISE NOTICE 'The PersonID must be valid, must not be person 1, and must not already be enabled';
        RAISE EXCEPTION 'Invalid PersonID' USING ERRCODE = 'P0001';
    END IF;
END;
$$ LANGUAGE plpgsql;
