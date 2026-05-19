-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateSupplierTransactionFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_supplier_transaction_from_json(
    p_supplier_transaction text,
    p_supplier_transaction_id integer,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    UPDATE purchasing.suppliertransactions SET
        "SupplierID"           = COALESCE(json.supplier_id, purchasing.suppliertransactions."SupplierID"),
        "TransactionTypeID"    = COALESCE(json.transaction_type_id, purchasing.suppliertransactions."TransactionTypeID"),
        "PurchaseOrderID"      = json.purchase_order_id,
        "PaymentMethodID"      = json.payment_method_id,
        "SupplierInvoiceNumber"= COALESCE(json.supplier_invoice_number, purchasing.suppliertransactions."SupplierInvoiceNumber"),
        "TransactionDate"      = COALESCE(json.transaction_date, purchasing.suppliertransactions."TransactionDate"),
        "AmountExcludingTax"   = COALESCE(json.amount_excluding_tax, purchasing.suppliertransactions."AmountExcludingTax"),
        "TaxAmount"            = COALESCE(json.tax_amount, purchasing.suppliertransactions."TaxAmount"),
        "TransactionAmount"    = COALESCE(json.transaction_amount, purchasing.suppliertransactions."TransactionAmount"),
        "OutstandingBalance"   = COALESCE(json.outstanding_balance, purchasing.suppliertransactions."OutstandingBalance"),
        "FinalizationDate"     = COALESCE(json.finalization_date, purchasing.suppliertransactions."FinalizationDate"),
        "LastEditedBy"         = p_user_id
    FROM jsonb_to_recordset(p_supplier_transaction::jsonb) AS json(
        supplier_id             integer,
        transaction_type_id     integer,
        purchase_order_id       integer,
        payment_method_id       integer,
        supplier_invoice_number varchar(20),
        transaction_date        date,
        amount_excluding_tax    numeric(18,2),
        tax_amount              numeric(18,2),
        transaction_amount      numeric(18,2),
        outstanding_balance     numeric(18,2),
        finalization_date       date
    )
    WHERE purchasing.suppliertransactions."SupplierTransactionID" = p_supplier_transaction_id;
END;
$$ LANGUAGE plpgsql;
