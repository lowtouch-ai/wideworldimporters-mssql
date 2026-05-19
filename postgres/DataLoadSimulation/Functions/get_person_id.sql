-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Functions/GetPersonID.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.get_person_id(
    p_full_name varchar(50)
) RETURNS integer AS $$
DECLARE
    _per_id integer;
BEGIN
    SELECT PersonID INTO _per_id
    FROM application.people
    WHERE FullName = p_full_name
      AND ValidTo = '9999-12-31 23:59:59.999999'
    LIMIT 1;

    RETURN _per_id;
END;
$$ LANGUAGE plpgsql;
