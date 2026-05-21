DO $$
BEGIN
  IF (SELECT COUNT(*) FROM sales.invoices) > 0 THEN RETURN; END IF;

  INSERT INTO sales.invoices
    (CustomerID, BillToCustomerID, OrderID, DeliveryMethodID, ContactPersonID,
     AccountsPersonID, SalespersonPersonID, PackedByPersonID,
     InvoiceDate, CustomerPurchaseOrderNumber, IsCreditNote,
     TotalDryItems, TotalChillerItems, LastEditedBy)
  SELECT
    o.CustomerID,
    o.CustomerID,
    o.OrderID,
    1,  -- Post
    o.ContactPersonID,
    4,  -- Isabella Rupp (accounts)
    o.SalespersonPersonID,
    5,  -- Eva Muirden (packing)
    o.OrderDate + INTERVAL '3 days',
    o.CustomerPurchaseOrderNumber,
    false,
    5, 0,
    2
  FROM sales.orders o;
END $$;
