DO $$
BEGIN
  IF (SELECT COUNT(*) FROM sales.orderlines) > 0 THEN RETURN; END IF;

  -- 3-5 lines per order using a spread of stock items (IDs 1-30), package type 7 = Each
  -- Quantities and items vary to give realistic dashboard variety
  INSERT INTO sales.orderlines
    (OrderID, StockItemID, Description, PackageTypeID, Quantity, UnitPrice,
     TaxRate, PickedQuantity, PickingCompletedWhen, LastEditedBy)
  SELECT
    o.OrderID,
    s.StockItemID,
    s.StockItemName,
    7,
    s.Qty,
    s.UnitPrice,
    15.000,
    s.Qty,
    o.OrderDate + INTERVAL '2 days',
    2
  FROM sales.orders o
  CROSS JOIN (
    VALUES
      (1,  'USB missile launcher (Green)',           25.00, 4),
      (4,  'USB food flash drive - sushi roll',      32.00, 6),
      (16, 'DBA joke mug - mind if I join you? (White)', 13.00, 10),
      (30, 'Developer joke mug - Oct 31 = Dec 25 (White)', 13.00, 8),
      (50, 'Ride on toy sedan car (Blue)',           345.00, 2)
  ) AS s(StockItemID, StockItemName, UnitPrice, Qty)
  WHERE s.StockItemID IN (SELECT StockItemID FROM warehouse.stockitems);
END $$;
