CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE VIEW webapi.cities AS
SELECT
    c.CityID,
    c.CityName,
    c.LatestRecordedPopulation,
    c.StateProvinceID,
    sp.StateProvinceName,
    -- TODO: verify JSON shape matches original FOR JSON PATH output
    json_build_object(
        'type', 'Feature',
        'geometry', json_build_object(
            'type', 'Point',
            'coordinates', json_build_array(ST_X(c.Location::geometry), ST_Y(c.Location::geometry))
        )
    ) AS Location
FROM application.cities c
JOIN application.state_provinces sp
    ON c.StateProvinceID = sp.StateProvinceID;
