-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Functions/GetCityLocation.sql
-- Requires: CREATE EXTENSION IF NOT EXISTS postgis;
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.get_city_location(
    p_city_id integer
) RETURNS geography AS $$
DECLARE
    _loc geography;
BEGIN
    SELECT Location INTO _loc
    FROM application.cities
    WHERE cityid = p_city_id
    LIMIT 1;

    RETURN _loc;
END;
$$ LANGUAGE plpgsql;
