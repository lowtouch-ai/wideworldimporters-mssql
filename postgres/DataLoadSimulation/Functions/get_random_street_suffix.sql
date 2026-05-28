-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomStreetSuffix.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.get_random_street_suffix(
) RETURNS varchar(20) AS $$
DECLARE
    v_suffix varchar(20);
BEGIN
    WITH suffixes(street) AS (
        VALUES ('Street'), ('Road'), ('Avenue'), ('Lane'), ('Drive'), ('Boulevard'),
               ('Court'), ('Circle'), ('Place'), ('Trail'), ('Path'), ('Loop'),
               ('Way'), ('Highway'), ('Alley')
    )
    SELECT street INTO v_suffix FROM suffixes ORDER BY random() LIMIT 1;

    RETURN v_suffix;
END;
$$ LANGUAGE plpgsql;
