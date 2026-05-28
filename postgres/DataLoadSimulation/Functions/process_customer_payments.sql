-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/ProcessCustomerPayments.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.process_customer_payments(
    p_current_date_time timestamp,
    p_starting_when     timestamp,
    p_end_of_time       timestamp,
    p_is_silent_mode    boolean
) RETURNS void AS $$
DECLARE
    v_staff_member_person_id integer;
BEGIN
    v_staff_member_person_id := dataloadsimulation.get_random_employee_person();

    CREATE TEMP TABLE transactions_to_receive (
        customer_transaction_id integer,
        customer_id             integer,
        invoice_id              integer,
        outstanding_balance     numeric(18,2)
    ) ON COMMIT DROP;

    INSERT INTO transactions_to_receive
        (customer_transaction_id, customer_id, invoice_id, outstanding_balance)
    SELECT "CustomerTransactionID", "CustomerID", "InvoiceID", "OutstandingBalance"
    FROM sales.customertransactions
    WHERE "IsFinalized" = false;

    UPDATE sales.customertransactions
    SET "OutstandingBalance" = 0,
        "FinalizationDate"   = p_starting_when,
        "LastEditedBy"       = v_staff_member_person_id,
        "LastEditedWhen"     = p_starting_when
    WHERE "CustomerTransactionID" IN (SELECT customer_transaction_id FROM transactions_to_receive);

    INSERT INTO sales.customertransactions
        ("CustomerID", "TransactionTypeID", "InvoiceID", "PaymentMethodID", "TransactionDate",
         "AmountExcludingTax", "TaxAmount", "TransactionAmount", "OutstandingBalance",
         "FinalizationDate", "LastEditedBy", "LastEditedWhen")
    SELECT ttr.customer_id, dataloadsimulation.get_transaction_type_id('Customer Payment Received'),
           NULL, dataloadsimulation.get_payment_method_id('EFT'),
           CAST(p_starting_when AS date), 0, 0, 0 - SUM(ttr.outstanding_balance),
           0, CAST(p_starting_when AS date), v_staff_member_person_id, p_starting_when
    FROM transactions_to_receive AS ttr
    GROUP BY ttr.customer_id;
END;
$$ LANGUAGE plpgsql;
