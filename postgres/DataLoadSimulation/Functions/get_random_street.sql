-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomStreet.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.get_random_street(
) RETURNS varchar(50) AS $$
DECLARE
    v_street_number varchar(10);
    v_street_name   varchar(20);
    v_street_suffix varchar(20);
BEGIN
    v_street_number := CAST((floor(random() * 8999)::integer + 100) AS varchar);
    v_street_name   := dataloadsimulation.get_random_street_name();
    v_street_suffix := dataloadsimulation.get_random_street_suffix();

    RETURN v_street_number || ' ' || v_street_name || ' ' || v_street_suffix;
END;
$$ LANGUAGE plpgsql;
