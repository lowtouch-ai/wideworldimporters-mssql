CREATE SCHEMA IF NOT EXISTS webapi;

-- isfinalized is a generated column derived from finalizationdate; do not insert it directly.
CREATE OR REPLACE FUNCTION webapi.insert_customer_transactions_from_json(
    p_customer_transactions text,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    INSERT INTO sales.customertransactions (
        CustomerID, TransactionTypeID, InvoiceID, PaymentMethodID,
        TransactionDate, AmountExcludingTax, TaxAmount, TransactionAmount,
        OutstandingBalance, FinalizationDate, LastEditedBy
    )
    SELECT
        x."CustomerID", x."TransactionTypeID", x."InvoiceID", x."PaymentMethodID",
        x."TransactionDate", x."AmountExcludingTax", x."TaxAmount",
        x."TransactionAmount", COALESCE(x."OutstandingBalance", x."TransactionAmount"),
        x."FinalizationDate", p_user_id
    FROM jsonb_to_recordset(
        CASE WHEN jsonb_typeof(p_customer_transactions::jsonb) = 'array'
             THEN p_customer_transactions::jsonb
             ELSE jsonb_build_array(p_customer_transactions::jsonb) END
    ) AS x(
        "CustomerID"         integer,
        "TransactionTypeID"  integer,
        "InvoiceID"          integer,
        "PaymentMethodID"    integer,
        "TransactionDate"    date,
        "AmountExcludingTax" numeric(18,2),
        "TaxAmount"          numeric(18,2),
        "TransactionAmount"  numeric(18,2),
        "OutstandingBalance" numeric(18,2),
        "FinalizationDate"   date
    );
END;
$$ LANGUAGE plpgsql;
