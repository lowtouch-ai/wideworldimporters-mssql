CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE VIEW webapi.customer_transactions AS
SELECT
    ct.CustomerTransactionID,
    ct.TransactionDate,
    ct.AmountExcludingTax,
    ct.TaxAmount,
    ct.TransactionAmount,
    ct.OutstandingBalance,
    ct.FinalizationDate,
    ct.IsFinalized,
    c.CustomerName,
    tt.TransactionTypeName,
    i.InvoiceDate,
    i.CustomerPurchaseOrderNumber,
    pm.PaymentMethodName,
    ct.CustomerID,
    ct.TransactionTypeID,
    ct.InvoiceID,
    ct.PaymentMethodID
FROM sales.customertransactions AS ct
    JOIN sales.customers AS c ON ct.CustomerID = c.CustomerID
    JOIN sales.invoices AS i ON ct.InvoiceID = i.InvoiceID
    LEFT JOIN application.transactiontypes AS tt ON ct.TransactionTypeID = tt.TransactionTypeID
    LEFT JOIN application.paymentmethods AS pm ON ct.PaymentMethodID = pm.PaymentMethodID;
