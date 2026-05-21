CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.insert_supplier_transactions_from_json(
    p_supplier_transactions text,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    INSERT INTO purchasing.suppliertransactions (
        SupplierID, TransactionTypeID, PurchaseOrderID, PaymentMethodID,
        SupplierInvoiceNumber, TransactionDate, AmountExcludingTax, TaxAmount,
        TransactionAmount, OutstandingBalance, FinalizationDate, LastEditedBy
    )
    SELECT
        x."SupplierID", x."TransactionTypeID", x."PurchaseOrderID", x."PaymentMethodID",
        x."SupplierInvoiceNumber", x."TransactionDate", x."AmountExcludingTax",
        x."TaxAmount", x."TransactionAmount", x."OutstandingBalance",
        x."FinalizationDate", p_user_id
    FROM jsonb_to_recordset(
        CASE WHEN jsonb_typeof(p_supplier_transactions::jsonb) = 'array'
             THEN p_supplier_transactions::jsonb
             ELSE jsonb_build_array(p_supplier_transactions::jsonb) END
    ) AS x(
        "SupplierID"            integer,
        "TransactionTypeID"     integer,
        "PurchaseOrderID"       integer,
        "PaymentMethodID"       integer,
        "SupplierInvoiceNumber" varchar(20),
        "TransactionDate"       date,
        "AmountExcludingTax"    numeric(18,2),
        "TaxAmount"             numeric(18,2),
        "TransactionAmount"     numeric(18,2),
        "OutstandingBalance"    numeric(18,2),
        "FinalizationDate"      date
    );
END;
$$ LANGUAGE plpgsql;
