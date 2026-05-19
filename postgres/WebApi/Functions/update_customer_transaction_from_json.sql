-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateCustomerTransactionFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_customer_transaction_from_json(
    p_customer_transaction text,
    p_customer_transaction_id integer,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    UPDATE sales.customertransactions SET
        TransactionTypeID = COALESCE(json.TransactionTypeID, sales.customertransactions.TransactionTypeID),
        PaymentMethodID = json.PaymentMethodID,
        TransactionDate = COALESCE(json.TransactionDate, sales.customertransactions.TransactionDate),
        AmountExcludingTax = COALESCE(json.AmountExcludingTax, sales.customertransactions.AmountExcludingTax),
        TaxAmount = COALESCE(json.TaxAmount, sales.customertransactions.TaxAmount),
        TransactionAmount = COALESCE(json.TransactionAmount, sales.customertransactions.TransactionAmount),
        OutstandingBalance = COALESCE(json.OutstandingBalance, sales.customertransactions.OutstandingBalance),
        FinalizationDate = json.FinalizationDate,
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_customer_transaction::jsonb) AS json(
        TransactionTypeID integer,
        PaymentMethodID integer,
        TransactionDate date,
        FinalizationDate date,
        AmountExcludingTax numeric(18,2),
        TaxAmount numeric(18,2),
        TransactionAmount numeric(18,2),
        OutstandingBalance numeric(18,2)
    )
    WHERE CustomerTransactionID = p_customer_transaction_id;
END;
$$ LANGUAGE plpgsql;
