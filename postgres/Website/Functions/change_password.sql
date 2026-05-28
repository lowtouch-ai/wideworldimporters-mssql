-- Converted from: wwi-ssdt/wwi-ssdt/Website/Stored Procedures/ChangePassword.sql
-- Requires: CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE SCHEMA IF NOT EXISTS website;

CREATE OR REPLACE FUNCTION website.change_password(
    p_person_id    integer,
    p_old_password varchar(40),
    p_new_password varchar(40)
) RETURNS void AS $$
DECLARE
    v_rowcount integer;
BEGIN
    UPDATE application.people
    SET ispermittedtologon = true,
        hashedpassword     = digest((p_new_password || fullname)::bytea, 'sha256')
    WHERE personid = p_person_id
      AND personid <> 1
      AND hashedpassword = digest((p_old_password || fullname)::bytea, 'sha256');

    GET DIAGNOSTICS v_rowcount = ROW_COUNT;
    IF v_rowcount = 0 THEN
        RAISE NOTICE 'The PersonID must be valid, and the old password must be valid.';
        RAISE NOTICE 'If the user has also changed name, please contact the IT staff to assist.';
        RAISE EXCEPTION 'Invalid Password Change';
    END IF;
END;
$$ LANGUAGE plpgsql;
