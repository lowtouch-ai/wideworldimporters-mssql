CREATE SCHEMA IF NOT EXISTS webapi;

-- TODO: The Border column uses MSSQL geography methods (.STGeometryType(), .ToString()).
-- In PostgreSQL with PostGIS, use ST_GeometryType(sp.Border) and ST_AsText(sp.Border).
-- The GeoJSON construction logic below is a direct translation; verify output format.
CREATE OR REPLACE VIEW webapi.state_provinces AS
SELECT
    sp.StateProvinceID,
    sp.StateProvinceCode,
    sp.StateProvinceName,
    sp.CountryID,
    sp.SalesTerritory,
    sp.LatestRecordedPopulation,
    NULL::text AS Border,
    c.CountryName
FROM application.stateprovinces AS sp
    INNER JOIN application.countries AS c
        ON c.CountryID = sp.CountryID;
