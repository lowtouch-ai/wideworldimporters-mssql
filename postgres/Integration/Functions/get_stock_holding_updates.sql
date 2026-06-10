-- Converted from: wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetStockHoldingUpdates.sql
CREATE SCHEMA IF NOT EXISTS integration;

CREATE OR REPLACE FUNCTION integration.get_stock_holding_updates(
) RETURNS TABLE (
    "Quantity On Hand" integer,
    "Bin Location" varchar(20),
    "Last Stocktake Quantity" integer,
    "Last Cost Price" numeric(18,2),
    "Reorder Level" integer,
    "Target Stock Level" integer,
    "WWI Stock Item ID" integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        sih.QuantityOnHand,
        sih.BinLocation,
        sih.LastStocktakeQuantity,
        sih.LastCostPrice,
        sih.ReorderLevel,
        sih.TargetStockLevel,
        sih.StockItemID
    FROM warehouse.stockitemholdings AS sih
    ORDER BY sih.StockItemID;
END;
$$ LANGUAGE plpgsql;
