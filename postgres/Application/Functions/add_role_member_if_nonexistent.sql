-- Converted from: wwi-ssdt/wwi-ssdt/Application/Stored Procedures/AddRoleMemberIfNonexistent.sql
CREATE SCHEMA IF NOT EXISTS application;

CREATE OR REPLACE FUNCTION application.add_role_member_if_nonexistent(
    p_role_name text,
    p_user_name text
) RETURNS void AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM pg_auth_members am
          JOIN pg_roles r ON am.roleid = r.oid
          JOIN pg_roles m ON am.member = m.oid
         WHERE r.rolname = p_role_name
           AND m.rolname = p_user_name
    ) THEN
        BEGIN
            EXECUTE format('GRANT %I TO %I', p_role_name, p_user_name);
            RAISE NOTICE 'User % added to role %', p_user_name, p_role_name;
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'Unable to add user % to role %', p_user_name, p_role_name;
            RAISE;
        END;
    END IF;
END;
$$ LANGUAGE plpgsql;
