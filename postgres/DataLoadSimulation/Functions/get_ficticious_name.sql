-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetFicticiousName.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.get_ficticious_name(
) RETURNS TABLE(first_name varchar(20), last_name varchar(20), full_name varchar(40), email varchar(200)) AS $$
BEGIN
    RETURN QUERY
    SELECT
        fnp."PreferredName"::varchar(20),
        fnp."LastName"::varchar(20),
        fnp."FullName"::varchar(40),
        fnp."ToEmail"::varchar(200)
    FROM dataloadsimulation.ficticiousnamepool fnp
    WHERE fnp."FullName" NOT IN (
        SELECT ap."FullName"
        FROM application.people ap
        WHERE ap."FullName" = fnp."FullName"
    )
    ORDER BY random()
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;
