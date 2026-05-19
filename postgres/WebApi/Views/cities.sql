CREATE SCHEMA IF NOT EXISTS webapi;

-- TODO: FOR JSON PATH not supported in PostgreSQL.
-- The Location column below uses json_build_object as an approximation.
-- Full GeoJSON Feature structure with geometry.coordinates requires PostGIS (ST_X/ST_Y).
-- Original MSSQL used: FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
CREATE OR REPLACE VIEW webapi.cities AS
SELECT
    c.CityID,
    c.CityName,
    c.LatestRecordedPopulation,
    c.StateProvinceID,
    sp.StateProvinceName,
    json_build_object(
        'type', 'Feature',
        'geometry', json_build_object(
            'type', 'Point',
            'coordinates', json_build_array(ST_X(c.Location), ST_Y(c.Location))
        )
    ) AS "Location"
FROM application.cities c
    INNER JOIN application.stateprovinces sp
        ON c.StateProvinceID = sp.StateProvinceID;
