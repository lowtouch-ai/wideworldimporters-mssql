-- Inserting one OrderLine in "Unknown" package needed to demonstrate parameter sniffing and FORCE LAST GOOD PLAN.
\echo 'Inserting single OrderLine in "Unknown" package.'

BEGIN;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM sales.orderlines) THEN
    RAISE EXCEPTION 'OrderLines must be loaded into the table before executing this script';
  END IF;
END;
$$;

-- Insert single order line record in package type = 0
-- This is prerequisite for Automatic tuning demo
INSERT INTO sales.orderlines (OrderID, StockItemID, Description, PackageTypeID, Quantity, UnitPrice, TaxRate, PickedQuantity, LastEditedBy)
SELECT OrderID, StockItemID, 'Unique OrderLine for Unknown package type', 0, Quantity, UnitPrice, TaxRate, PickedQuantity, LastEditedBy
FROM sales.orderlines
WHERE Quantity IS NOT NULL AND UnitPrice IS NOT NULL
ORDER BY random()
LIMIT 1;

COMMIT;
