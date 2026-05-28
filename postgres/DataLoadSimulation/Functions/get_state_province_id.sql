-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Functions/GetStateProvinceID.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.get_state_province_id(
    p_state_province_code varchar(5)
) RETURNS integer AS $$
DECLARE
    _sp_id integer;
BEGIN
    SELECT StateProvinceID INTO _sp_id
    FROM application.state_provinces
    WHERE StateProvinceCode = p_state_province_code
      AND ValidTo = '9999-12-31 23:59:59.999999';

    RETURN _sp_id;
END;
$$ LANGUAGE plpgsql;
