-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateCustomerTransactionFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_customer_transaction_from_json(
    p_customer_transaction    text,
    p_customer_transaction_id integer,
    p_user_id                 integer
) RETURNS void AS $$
BEGIN
    -- FinalizationDate: direct assignment (allows NULL to clear)
    -- PaymentMethodID: direct assignment (allows NULL)
    UPDATE sales.customertransactions
    SET transactiontypeid  = COALESCE(x."TransactionTypeID",  customertransactions.transactiontypeid),
        paymentmethodid    = x."PaymentMethodID",
        transactiondate    = COALESCE(x."TransactionDate",    customertransactions.transactiondate),
        amountexcludingtax = COALESCE(x."AmountExcludingTax", customertransactions.amountexcludingtax),
        taxamount          = COALESCE(x."TaxAmount",          customertransactions.taxamount),
        transactionamount  = COALESCE(x."TransactionAmount",  customertransactions.transactionamount),
        outstandingbalance = COALESCE(x."OutstandingBalance", customertransactions.outstandingbalance),
        finalizationdate   = x."FinalizationDate",
        lasteditedby       = p_user_id
    FROM jsonb_to_record(p_customer_transaction::jsonb) AS x(
        "TransactionTypeID"  integer,
        "PaymentMethodID"    integer,
        "TransactionDate"    date,
        "FinalizationDate"   date,
        "AmountExcludingTax" numeric(18,2),
        "TaxAmount"          numeric(18,2),
        "TransactionAmount"  numeric(18,2),
        "OutstandingBalance" numeric(18,2)
    )
    WHERE customertransactions.customertransactionid = p_customer_transaction_id;
END;
$$ LANGUAGE plpgsql;
