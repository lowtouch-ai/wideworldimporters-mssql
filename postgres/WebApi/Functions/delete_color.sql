-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteColor.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.delete_color(
    p_color_id integer
) RETURNS void AS $$
BEGIN
    DELETE FROM warehouse.colors
    WHERE ColorID = p_color_id;
END;
$$ LANGUAGE plpgsql;
