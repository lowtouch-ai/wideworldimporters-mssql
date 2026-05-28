-- Converted from: wwi-ssdt/wwi-ssdt/Website/Stored Procedures/ActivateWebsiteLogon.sql
-- Requires: CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE SCHEMA IF NOT EXISTS website;

CREATE OR REPLACE FUNCTION website.activate_website_logon(
    p_person_id      integer,
    p_logon_name     varchar(50),
    p_initial_password varchar(40)
) RETURNS void AS $$
DECLARE
    v_rowcount integer;
BEGIN
    UPDATE application.people
    SET ispermittedtologon = true,
        logonname          = p_logon_name,
        hashedpassword     = digest((p_initial_password || fullname)::bytea, 'sha256'),
        userpreferences    = (SELECT userpreferences FROM application.people WHERE personid = 1)
    WHERE personid = p_person_id
      AND personid <> 1
      AND ispermittedtologon = false;

    GET DIAGNOSTICS v_rowcount = ROW_COUNT;
    IF v_rowcount = 0 THEN
        RAISE NOTICE 'The PersonID must be valid, must not be person 1, and must not already be enabled';
        RAISE EXCEPTION 'Invalid PersonID';
    END IF;
END;
$$ LANGUAGE plpgsql;
