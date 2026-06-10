-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateColorFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_color_from_json(
    p_color text,
    p_color_id integer,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    UPDATE warehouse.colors SET
        ColorName = json.ColorName,
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_color::jsonb) AS json(ColorName varchar(50))
    WHERE ColorID = p_color_id;
END;
$$ LANGUAGE plpgsql;
