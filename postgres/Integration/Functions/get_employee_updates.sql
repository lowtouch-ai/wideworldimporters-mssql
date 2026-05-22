-- Converted from: wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetEmployeeUpdates.sql
CREATE SCHEMA IF NOT EXISTS integration;

CREATE OR REPLACE FUNCTION integration.get_employee_updates(
    p_last_cutoff timestamp,
    p_new_cutoff  timestamp
) RETURNS TABLE(
    "WWI Employee ID"  integer,
    "Employee"         varchar(50),
    "Preferred Name"   varchar(50),
    "Is Salesperson"   boolean,
    "Photo"            bytea,
    "Valid From"       timestamp,
    "Valid To"         timestamp
) AS $$
DECLARE
    rec RECORD;
    _end_of_time timestamp := '9999-12-31 23:59:59.9999999';
BEGIN
    DROP TABLE IF EXISTS employeechanges;
    CREATE TEMP TABLE employeechanges (
        "WWI Employee ID"  integer,
        "Employee"         varchar(50),
        "Preferred Name"   varchar(50),
        "Is Salesperson"   boolean,
        "Photo"            bytea,
        "Valid From"       timestamp,
        "Valid To"         timestamp
    );

    -- Cursor converted to FOR loop: UNION ALL of archive + current employee changes ordered by ValidFrom
    -- Filter: IsEmployee = true (was IsEmployee <> 0 on bit column)
    FOR rec IN
        SELECT p.PersonID,
               p.ValidFrom
        FROM application.people_archive AS p
        WHERE p.ValidFrom > p_last_cutoff
          AND p.ValidFrom <= p_new_cutoff
          AND p.IsEmployee = true
        UNION ALL
        SELECT p.PersonID,
               p.ValidFrom
        FROM application.people AS p
        WHERE p.ValidFrom > p_last_cutoff
          AND p.ValidFrom <= p_new_cutoff
          AND p.IsEmployee = true
        ORDER BY ValidFrom
    LOOP
        -- TODO: FOR SYSTEM_TIME AS OF rec.validfrom not supported natively in PostgreSQL.
        -- Approximation: query archive for the version valid at rec.validfrom (ValidFrom <= ts AND ValidTo > ts),
        -- falling back to the current-table row if no archive match, taking the most recent version.
        INSERT INTO employeechanges ("WWI Employee ID", "Employee", "Preferred Name", "Is Salesperson", "Photo", "Valid From", "Valid To")
        SELECT p.PersonID, p.FullName, p.PreferredName, p.IsSalesperson, p.Photo, p.ValidFrom, p.ValidTo
        FROM (
            SELECT PersonID, FullName, PreferredName, IsSalesperson, Photo, ValidFrom, ValidTo
            FROM application.people_archive
            WHERE PersonID = rec.personid
              AND ValidFrom <= rec.validfrom
              AND ValidTo > rec.validfrom
            UNION ALL
            SELECT PersonID, FullName, PreferredName, IsSalesperson, Photo, ValidFrom,
                   CAST('9999-12-31 23:59:59.9999999' AS timestamp) AS ValidTo
            FROM application.people
            WHERE PersonID = rec.personid
              AND ValidFrom <= rec.validfrom
            ORDER BY ValidFrom DESC
            LIMIT 1
        ) AS p;
    END LOOP;

    CREATE INDEX ix_employeechanges ON employeechanges ("WWI Employee ID", "Valid From");

    -- Update Valid To: min(Valid From) of a later row for the same employee, or end-of-time
    UPDATE employeechanges AS cc
    SET "Valid To" = COALESCE(
        (SELECT MIN(cc2."Valid From")
         FROM employeechanges AS cc2
         WHERE cc2."WWI Employee ID" = cc."WWI Employee ID"
           AND cc2."Valid From" > cc."Valid From"),
        _end_of_time
    );

    RETURN QUERY
    SELECT cc."WWI Employee ID", cc."Employee", cc."Preferred Name", cc."Is Salesperson",
           cc."Photo", cc."Valid From", cc."Valid To"
    FROM employeechanges AS cc
    ORDER BY cc."Valid From";

    DROP TABLE IF EXISTS employeechanges;
END;
$$ LANGUAGE plpgsql;
