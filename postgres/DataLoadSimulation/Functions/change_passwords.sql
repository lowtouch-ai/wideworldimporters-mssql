-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/ChangePasswords.sql
-- Requires: CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.change_passwords(
    p_current_date_time timestamp,
    p_starting_when     timestamp,
    p_end_of_time       timestamp,
    p_is_silent_mode    boolean
) RETURNS void AS $$
DECLARE
    v_number_to_change integer;
    v_counter          integer := 0;
    v_person_id        integer;
    v_full_name        varchar(50);
BEGIN
    SELECT q."Quantity" INTO v_number_to_change
    FROM (VALUES (0), (0), (0), (0), (0), (1), (1), (2)) AS q("Quantity")
    ORDER BY random()
    LIMIT 1;

    WHILE v_counter < v_number_to_change LOOP
        SELECT "PersonID", "FullName"
        INTO v_person_id, v_full_name
        FROM application.people
        WHERE "IsPermittedToLogon" <> false AND "PersonID" <> 1
        ORDER BY random()
        LIMIT 1;

        UPDATE application.people
        SET "HashedPassword" = digest('SQLRocks!00' || v_full_name, 'sha256'),
            "ValidFrom"      = p_starting_when
        WHERE "PersonID" = v_person_id;

        v_counter := v_counter + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
