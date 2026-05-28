-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomCity.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.get_random_city(
) RETURNS TABLE(city_id integer, city_name varchar(50), state_province_code varchar(5), state_province_name varchar(50), area_code varchar(4)) AS $$
DECLARE
    v_city_id integer;
BEGIN
    LOOP
        SELECT c."CityID", c."CityName"::varchar(50), s."StateProvinceCode"::varchar(5), s."StateProvinceName"::varchar(50), a."AreaCode"::varchar(4)
        INTO v_city_id, city_name, state_province_code, state_province_name, area_code
        FROM application.cities c
        JOIN application.stateprovinces s ON c."StateProvinceID" = s."StateProvinceID"
        JOIN dataloadsimulation.areacode a ON a."StateProvinceCode" = s."StateProvinceCode"
        ORDER BY random()
        LIMIT 1;

        EXIT WHEN v_city_id IS NOT NULL;
    END LOOP;

    city_id := v_city_id;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;
