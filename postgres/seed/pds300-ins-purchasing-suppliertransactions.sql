DO $body$
BEGIN
IF (SELECT COUNT(*) FROM purchasing.suppliertransactions) = 0 THEN

-- TransactionTypeID 5 = Supplier Invoice, 7 = Supplier Payment Issued
-- PaymentMethodID 4 = EFT, 1 = Cash, NULL = invoice (not yet paid)
INSERT INTO purchasing.suppliertransactions
  (SupplierTransactionID, SupplierID, TransactionTypeID, PurchaseOrderID, PaymentMethodID,
   SupplierInvoiceNumber, TransactionDate, AmountExcludingTax, TaxAmount,
   TransactionAmount, OutstandingBalance, FinalizationDate, LastEditedBy)
VALUES
  (1, 1, 5, 1, NULL, 'INV-A001', '2020-01-19', 1375.00, 137.50, 1512.50, 1512.50, NULL,         1)
, (2, 2, 5, 2, NULL, 'INV-B002', '2020-01-24',  740.00,  74.00,  814.00,    0.00, '2020-02-05', 1)
, (3, 2, 7, 2, 4,    NULL,       '2020-02-05',  814.00,   0.00,  814.00,    0.00, '2020-02-05', 1)
, (4, 3, 5, 3, NULL, 'INV-C003', '2020-02-17', 2288.00, 228.80, 2516.80, 2516.80, NULL,         1)
, (5, 4, 5, 4, NULL, 'INV-D004', '2020-02-28', 3680.00, 368.00, 4048.00,    0.00, '2020-03-10', 1)
, (6, 4, 7, 4, 4,    NULL,       '2020-03-10', 4048.00,   0.00, 4048.00,    0.00, '2020-03-10', 1)
, (7, 5, 5, 5, NULL, 'INV-E005', '2020-03-15', 4800.00, 480.00, 5280.00, 5280.00, NULL,         1)
, (8, 6, 5, 6, NULL, 'INV-F006', '2020-04-03', 8050.00, 805.00, 8855.00,    0.00, '2020-04-15', 1)
, (9, 6, 7, 6, 1,    NULL,       '2020-04-15', 8855.00,   0.00, 8855.00,    0.00, '2020-04-15', 1)
;

END IF;
END;
$body$;
