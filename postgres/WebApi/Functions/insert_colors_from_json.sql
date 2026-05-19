-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertColorsFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.insert_colors_from_json(
    p_colors  text,
    p_user_id integer
) RETURNS TABLE(colorid integer) AS $$
BEGIN
    RETURN QUERY
    INSERT INTO warehouse.colors(colorname, lasteditedby)
    SELECT x."ColorName", p_user_id
    FROM jsonb_to_recordset(p_colors::jsonb) AS x("ColorName" varchar(50))
    RETURNING colors.colorid;
END;
$$ LANGUAGE plpgsql;
