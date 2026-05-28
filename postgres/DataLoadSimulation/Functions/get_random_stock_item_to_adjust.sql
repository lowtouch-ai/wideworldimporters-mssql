-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomStockItemToAdjust.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.get_random_stock_item_to_adjust(
    p_quantity_to_adjust integer
) RETURNS integer AS $$
DECLARE
    v_id integer;
BEGIN
    SELECT "StockItemID" INTO v_id
    FROM warehouse.stockitemholdings
    WHERE ("QuantityOnHand" + p_quantity_to_adjust) >= 0
    ORDER BY random()
    LIMIT 1;

    RETURN v_id;
END;
$$ LANGUAGE plpgsql;
