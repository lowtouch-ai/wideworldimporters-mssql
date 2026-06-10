-- Converted from: wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetEmployeeUpdates.sql
CREATE SCHEMA IF NOT EXISTS integration;

-- TODO: FOR SYSTEM_TIME AS OF not supported natively in PostgreSQL.
-- Rewritten using archive tables with ValidFrom/ValidTo range filtering.

CREATE OR REPLACE FUNCTION integration.get_employee_updates(
    p_LastCutoff timestamp(6),
    p_NewCutoff timestamp(6)
) RETURNS TABLE (
    "WWI Employee ID" integer,
    "Employee" varchar(50),
    "Preferred Name" varchar(50),
    "Is Salesperson" boolean,
    "Photo" bytea,
    "Valid From" timestamp(6),
    "Valid To" timestamp(6)
) AS $$
DECLARE
    _EndOfTime timestamp(6) := '9999-12-31 23:59:59.999999';
    _PersonID integer;
    _ValidFrom timestamp(6);
BEGIN
    CREATE TEMP TABLE _employee_changes (
        "WWI Employee ID" integer,
        "Employee" varchar(50),
        "Preferred Name" varchar(50),
        "Is Salesperson" boolean,
        "Photo" bytea,
        "Valid From" timestamp(6),
        "Valid To" timestamp(6)
    ) ON COMMIT DROP;

    FOR _PersonID, _ValidFrom IN
        SELECT p.PersonID, p.ValidFrom
        FROM application.people_archive AS p
        WHERE p.ValidFrom > p_LastCutoff AND p.ValidFrom <= p_NewCutoff AND p.IsEmployee <> false
        UNION ALL
        SELECT p.PersonID, p.ValidFrom
        FROM application.people AS p
        WHERE p.ValidFrom > p_LastCutoff AND p.ValidFrom <= p_NewCutoff AND p.IsEmployee <> false
        ORDER BY ValidFrom
    LOOP
        INSERT INTO _employee_changes
        SELECT p.PersonID, p.FullName, p.PreferredName, p.IsSalesperson, p.Photo,
               p.ValidFrom, p.ValidTo
        FROM (
            SELECT * FROM application.people_archive
            WHERE PersonID = _PersonID
              AND ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL
            SELECT * FROM application.people
            WHERE PersonID = _PersonID
              AND ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS p;
    END LOOP;

    UPDATE _employee_changes AS cc
    SET "Valid To" = COALESCE(
        (SELECT MIN(cc2."Valid From") FROM _employee_changes AS cc2
         WHERE cc2."WWI Employee ID" = cc."WWI Employee ID"
           AND cc2."Valid From" > cc."Valid From"),
        _EndOfTime
    );

    RETURN QUERY
    SELECT * FROM _employee_changes ORDER BY "Valid From";
END;
$$ LANGUAGE plpgsql;
