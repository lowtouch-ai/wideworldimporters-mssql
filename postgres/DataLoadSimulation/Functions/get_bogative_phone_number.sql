-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Functions/GetBogativePhoneNumber.sql
-- Note: source was a stored procedure with an OUTPUT parameter; converted to a scalar function.
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.get_bogative_phone_number(
    p_area_code varchar(4)
) RETURNS varchar(20) AS $$
DECLARE
    _phone_last4 varchar(4);
BEGIN
    -- ABS(CHECKSUM(NEWID())) % 9999 → random integer in [0, 9998]
    _phone_last4 := lpad((floor(random() * 9999))::integer::text, 4, '0');

    RETURN '(' || p_area_code || ') 555-' || _phone_last4;
END;
$$ LANGUAGE plpgsql;
