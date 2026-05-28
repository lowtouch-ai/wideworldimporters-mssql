-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateColorFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_color_from_json(
    p_color    text,
    p_color_id integer,
    p_user_id  integer
) RETURNS void AS $$
BEGIN
    UPDATE warehouse.colors
    SET colorname    = x."ColorName",
        lasteditedby = p_user_id
    FROM jsonb_to_record(p_color::jsonb) AS x("ColorName" varchar(50))
    WHERE colors.colorid = p_color_id;
END;
$$ LANGUAGE plpgsql;
