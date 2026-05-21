DO $$
BEGIN
  IF (SELECT COUNT(*) FROM sales.invoicelines) > 0 THEN RETURN; END IF;

  INSERT INTO sales.invoicelines
    (InvoiceID, StockItemID, Description, PackageTypeID, Quantity,
     UnitPrice, TaxRate, TaxAmount, LineProfit, ExtendedPrice, LastEditedBy)
  SELECT
    i.InvoiceID,
    ol.StockItemID,
    ol.Description,
    ol.PackageTypeID,
    ol.Quantity,
    ol.UnitPrice,
    ol.TaxRate,
    ROUND(ol.Quantity * ol.UnitPrice * ol.TaxRate / 100, 2),
    ROUND(ol.Quantity * ol.UnitPrice * 0.35, 2),
    ROUND(ol.Quantity * ol.UnitPrice * (1 + ol.TaxRate / 100), 2),
    2
  FROM sales.invoices i
  JOIN sales.orderlines ol ON ol.OrderID = i.OrderID;
END $$;
