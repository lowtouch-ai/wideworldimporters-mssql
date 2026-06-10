DO $$
DECLARE
  v_tt_inv INT := 1;  -- Customer Invoice
  v_tt_pay INT := 3;  -- Customer Payment Received
BEGIN
  IF (SELECT COUNT(*) FROM sales.customertransactions) > 0 THEN RETURN; END IF;

  -- Invoice transaction per invoice
  INSERT INTO sales.customertransactions
    (CustomerID, TransactionTypeID, InvoiceID, PaymentMethodID,
     TransactionDate, AmountExcludingTax, TaxAmount, TransactionAmount,
     OutstandingBalance, LastEditedBy)
  SELECT
    i.CustomerID, v_tt_inv, i.InvoiceID, NULL,
    i.InvoiceDate,
    ROUND(SUM(il.ExtendedPrice / (1 + il.TaxRate / 100)), 2),
    ROUND(SUM(il.TaxAmount), 2),
    ROUND(SUM(il.ExtendedPrice), 2),
    ROUND(SUM(il.ExtendedPrice), 2),
    2
  FROM sales.invoices i
  JOIN sales.invoicelines il ON il.InvoiceID = i.InvoiceID
  GROUP BY i.InvoiceID, i.CustomerID, i.InvoiceDate;

  -- Payment received 14 days later, clearing the balance
  INSERT INTO sales.customertransactions
    (CustomerID, TransactionTypeID, InvoiceID, PaymentMethodID,
     TransactionDate, AmountExcludingTax, TaxAmount, TransactionAmount,
     OutstandingBalance, FinalizationDate, LastEditedBy)
  SELECT
    ct.CustomerID, v_tt_pay, ct.InvoiceID, (1 + (ct.InvoiceID % 4)),
    ct.TransactionDate + INTERVAL '14 days',
    -ct.AmountExcludingTax, -ct.TaxAmount, -ct.TransactionAmount,
    0, ct.TransactionDate + INTERVAL '14 days',
    2
  FROM sales.customertransactions ct
  WHERE ct.TransactionTypeID = v_tt_inv;
END $$;
