-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/ActivateWebsiteLogons.sql
-- Requires: CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.activate_website_logons(
    p_current_date_time timestamp,
    p_starting_when     timestamp,
    p_end_of_time       timestamp,
    p_is_silent_mode    boolean
) RETURNS void AS $$
DECLARE
    v_number_to_activate integer;
    v_counter            integer := 0;
    v_person_id          integer;
    v_email_address      varchar(256);
    v_full_name          varchar(50);
    v_user_preferences   text;
BEGIN
    v_number_to_activate := CASE WHEN (random() * 8) <= 1 THEN 1 ELSE 0 END;

    SELECT "UserPreferences" INTO v_user_preferences
    FROM application.people WHERE "PersonID" = 1;

    WHILE v_counter < v_number_to_activate LOOP
        SELECT "PersonID", "EmailAddress", "FullName"
        INTO v_person_id, v_email_address, v_full_name
        FROM application.people
        WHERE "IsPermittedToLogon" = false AND "PersonID" <> 1
        ORDER BY random()
        LIMIT 1;

        UPDATE application.people
        SET "IsPermittedToLogon" = true,
            "LogonName"          = v_email_address,
            "HashedPassword"     = digest('SQLRocks!00' || v_full_name, 'sha256'),
            "UserPreferences"    = v_user_preferences,
            "ValidFrom"          = p_starting_when
        WHERE "PersonID" = v_person_id;

        v_counter := v_counter + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
