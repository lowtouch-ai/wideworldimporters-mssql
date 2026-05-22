CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.delete_special_deal(
    p_special_deal_id integer
) RETURNS void AS $$
BEGIN
    DELETE FROM sales.specialdeals
    WHERE SpecialDealID = p_special_deal_id;
END;
$$ LANGUAGE plpgsql;
