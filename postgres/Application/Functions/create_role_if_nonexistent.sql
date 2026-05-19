-- Converted from: wwi-ssdt/wwi-ssdt/Application/Stored Procedures/CreateRoleIfNonexistent.sql
CREATE SCHEMA IF NOT EXISTS application;

CREATE OR REPLACE FUNCTION application.create_role_if_nonexistent(
    p_role_name text
) RETURNS void AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = p_role_name) THEN
        BEGIN
            EXECUTE format('CREATE ROLE %I', p_role_name);
            RAISE NOTICE 'Role % created', p_role_name;
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'Unable to create role %', p_role_name;
            RAISE;
        END;
    END IF;
END;
$$ LANGUAGE plpgsql;
