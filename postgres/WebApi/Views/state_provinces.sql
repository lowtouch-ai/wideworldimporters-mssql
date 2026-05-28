CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE VIEW webapi.state_provinces AS
SELECT
    sp.StateProvinceID,
    sp.StateProvinceCode,
    sp.StateProvinceName,
    sp.CountryID,
    sp.SalesTerritory,
    sp.LatestRecordedPopulation,
    -- TODO: verify JSON shape matches original FOR JSON PATH output
    json_build_object(
        'type', 'Feature',
        'geometry', ST_AsGeoJSON(sp.Border::geometry)::json
    ) AS Border,
    c.CountryName
FROM application.state_provinces AS sp
JOIN application.countries AS c ON c.CountryID = sp.CountryID;
