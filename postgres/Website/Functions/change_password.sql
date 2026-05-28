-- Converted from: wwi-ssdt/wwi-ssdt/Website/Stored Procedures/ChangePassword.sql
CREATE SCHEMA IF NOT EXISTS website;

CREATE OR REPLACE FUNCTION website.change_password(
    p_PersonID integer,
    p_OldPassword varchar(40),
    p_NewPassword varchar(40)
) RETURNS void AS $$
DECLARE
    _rowcount integer;
BEGIN
    -- NOTE: HASHBYTES('SHA2_256', ...) has no direct PostgreSQL equivalent.
    -- TODO: Replace with pgcrypto: encode(digest(password || FullName, 'sha256'), 'hex')
    -- Requires: CREATE EXTENSION IF NOT EXISTS pgcrypto;
    UPDATE application.people
    SET IsPermittedToLogon = true,
        HashedPassword = encode(digest(p_NewPassword || FullName, 'sha256'), 'hex')
    WHERE PersonID = p_PersonID
    AND PersonID <> 1
    AND HashedPassword = encode(digest(p_OldPassword || FullName, 'sha256'), 'hex');

    GET DIAGNOSTICS _rowcount = ROW_COUNT;

    IF _rowcount = 0 THEN
        RAISE NOTICE 'The PersonID must be valid, and the old password must be valid.';
        RAISE NOTICE 'If the user has also changed name, please contact the IT staff to assist.';
        RAISE EXCEPTION 'Invalid Password Change' USING ERRCODE = 'P0001';
    END IF;
END;
$$ LANGUAGE plpgsql;
