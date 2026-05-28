-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateSupplierTransactionFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_supplier_transaction_from_json(
    p_supplier_transaction text,
    p_supplier_transaction_id integer,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    UPDATE purchasing.suppliertransactions SET
        SupplierID = COALESCE(json.SupplierID, purchasing.suppliertransactions.SupplierID),
        TransactionTypeID = COALESCE(json.TransactionTypeID, purchasing.suppliertransactions.TransactionTypeID),
        PurchaseOrderID = json.PurchaseOrderID,
        PaymentMethodID = json.PaymentMethodID,
        SupplierInvoiceNumber = COALESCE(json.SupplierInvoiceNumber, purchasing.suppliertransactions.SupplierInvoiceNumber),
        TransactionDate = COALESCE(json.TransactionDate, purchasing.suppliertransactions.TransactionDate),
        AmountExcludingTax = COALESCE(json.AmountExcludingTax, purchasing.suppliertransactions.AmountExcludingTax),
        TaxAmount = COALESCE(json.TaxAmount, purchasing.suppliertransactions.TaxAmount),
        TransactionAmount = COALESCE(json.TransactionAmount, purchasing.suppliertransactions.TransactionAmount),
        OutstandingBalance = COALESCE(json.OutstandingBalance, purchasing.suppliertransactions.OutstandingBalance),
        FinalizationDate = COALESCE(json.FinalizationDate, purchasing.suppliertransactions.FinalizationDate),
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_supplier_transaction::jsonb) AS json(
        SupplierID integer,
        TransactionTypeID integer,
        PurchaseOrderID integer,
        PaymentMethodID integer,
        SupplierInvoiceNumber varchar(20),
        TransactionDate date,
        AmountExcludingTax numeric(18,2),
        TaxAmount numeric(18,2),
        TransactionAmount numeric(18,2),
        OutstandingBalance numeric(18,2),
        FinalizationDate date
    )
    WHERE SupplierTransactionID = p_supplier_transaction_id;
END;
$$ LANGUAGE plpgsql;
