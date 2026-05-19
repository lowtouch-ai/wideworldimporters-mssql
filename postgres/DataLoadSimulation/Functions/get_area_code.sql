-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Functions/GetAreaCode.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.get_area_code(
    p_state_province_code varchar(4)
) RETURNS varchar(4) AS $$
DECLARE
    _area_code varchar(4);
BEGIN
    SELECT ac.AreaCode INTO _area_code
    FROM dataloadsimulation.areacode AS ac
    WHERE ac.StateProvinceCode = p_state_province_code
    LIMIT 1;

    RETURN _area_code;
END;
$$ LANGUAGE plpgsql;
