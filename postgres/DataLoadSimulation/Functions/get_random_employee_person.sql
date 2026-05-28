-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomEmployeePerson.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.get_random_employee_person(
) RETURNS integer AS $$
DECLARE
    v_id integer;
BEGIN
    SELECT "PersonID" INTO v_id
    FROM application.people
    WHERE "IsEmployee" <> false
      AND "ValidTo" = '9999-12-31 23:59:59.999999'
    ORDER BY random()
    LIMIT 1;

    RETURN v_id;
END;
$$ LANGUAGE plpgsql;
