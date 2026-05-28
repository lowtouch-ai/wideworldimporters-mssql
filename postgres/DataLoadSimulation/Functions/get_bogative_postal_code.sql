-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetBogativePostalCode.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.get_bogative_postal_code(
    p_city_id integer
) RETURNS varchar(10) AS $$
DECLARE
    v_country_name varchar(60);
BEGIN
    SELECT o."CountryName" INTO v_country_name
    FROM application.cities c
    JOIN application.stateprovinces s ON c."StateProvinceID" = s."StateProvinceID"
    JOIN application.countries o ON s."CountryID" = o."CountryID"
    WHERE c."CityID" = p_city_id
      AND c."ValidTo" = '9999-12-31 23:59:59.999999'
    LIMIT 1;

    RETURN CASE v_country_name
        WHEN 'United States' THEN LPAD(CAST(floor(random() * 99999)::integer AS varchar), 5, '0')
        ELSE LPAD(CAST(floor(random() * 99999)::integer AS varchar), 5, '0')
    END;
END;
$$ LANGUAGE plpgsql;
