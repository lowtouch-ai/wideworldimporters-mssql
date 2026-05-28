-- Converted from: wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetTransactionUpdates.sql
CREATE SCHEMA IF NOT EXISTS integration;

CREATE OR REPLACE FUNCTION integration.get_transaction_updates(
    p_last_cutoff timestamp,
    p_new_cutoff  timestamp
) RETURNS TABLE(
    "Date Key"                          date,
    "WWI Customer Transaction ID"       integer,
    "WWI Supplier Transaction ID"       integer,
    "WWI Invoice ID"                    integer,
    "WWI Purchase Order ID"             integer,
    "Supplier Invoice Number"           varchar(20),
    "Total Excluding Tax"               numeric(18,2),
    "Tax Amount"                        numeric(18,3),
    "Total Including Tax"               numeric(18,2),
    "Outstanding Balance"               numeric(18,2),
    "Is Finalized"                      boolean,
    "WWI Customer ID"                   integer,
    "WWI Bill To Customer ID"           integer,
    "WWI Supplier ID"                   integer,
    "WWI Transaction Type ID"           integer,
    "WWI Payment Method ID"             integer,
    "Last Modified When"                timestamp
) AS $$
BEGIN
    RETURN QUERY
    SELECT CAST(ct.TransactionDate AS date),
           ct.CustomerTransactionID,
           CAST(NULL AS integer),
           ct.InvoiceID,
           CAST(NULL AS integer),
           CAST(NULL AS varchar(20)),
           ct.AmountExcludingTax,
           ct.TaxAmount,
           ct.TransactionAmount,
           ct.OutstandingBalance,
           ct.IsFinalized,
           COALESCE(i.CustomerID, ct.CustomerID),
           ct.CustomerID,
           CAST(NULL AS integer),
           ct.TransactionTypeID,
           ct.PaymentMethodID,
           ct.LastEditedWhen
    FROM sales.customertransactions AS ct
    LEFT OUTER JOIN sales.invoices AS i ON ct.InvoiceID = i.InvoiceID
    WHERE ct.LastEditedWhen > p_last_cutoff
      AND ct.LastEditedWhen <= p_new_cutoff

    UNION ALL

    SELECT CAST(st.TransactionDate AS date),
           CAST(NULL AS integer),
           st.SupplierTransactionID,
           CAST(NULL AS integer),
           st.PurchaseOrderID,
           st.SupplierInvoiceNumber,
           st.AmountExcludingTax,
           st.TaxAmount,
           st.TransactionAmount,
           st.OutstandingBalance,
           st.IsFinalized,
           CAST(NULL AS integer),
           CAST(NULL AS integer),
           st.SupplierID,
           st.TransactionTypeID,
           st.PaymentMethodID,
           st.LastEditedWhen
    FROM purchasing.suppliertransactions AS st
    WHERE st.LastEditedWhen > p_last_cutoff
      AND st.LastEditedWhen <= p_new_cutoff;
END;
$$ LANGUAGE plpgsql;
