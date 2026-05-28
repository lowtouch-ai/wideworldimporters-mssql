-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/PaySuppliers.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.pay_suppliers(
    p_current_date_time timestamp,
    p_starting_when     timestamp,
    p_end_of_time       timestamp,
    p_is_silent_mode    boolean
) RETURNS void AS $$
DECLARE
    v_staff_member_person_id integer;
BEGIN
    SELECT "PersonID" INTO v_staff_member_person_id
    FROM application.people
    WHERE "IsEmployee" <> false
    ORDER BY random()
    LIMIT 1;

    CREATE TEMP TABLE transactions_to_pay (
        supplier_transaction_id integer,
        supplier_id             integer,
        purchase_order_id       integer,
        supplier_invoice_number varchar(20),
        outstanding_balance     numeric(18,2)
    ) ON COMMIT DROP;

    INSERT INTO transactions_to_pay
        (supplier_transaction_id, supplier_id, purchase_order_id, supplier_invoice_number, outstanding_balance)
    SELECT "SupplierTransactionID", "SupplierID", "PurchaseOrderID", "SupplierInvoiceNumber", "OutstandingBalance"
    FROM purchasing.suppliertransactions
    WHERE "IsFinalized" = false;

    UPDATE purchasing.suppliertransactions
    SET "OutstandingBalance" = 0,
        "FinalizationDate"   = p_starting_when,
        "LastEditedBy"       = v_staff_member_person_id,
        "LastEditedWhen"     = p_starting_when
    WHERE "SupplierTransactionID" IN (SELECT supplier_transaction_id FROM transactions_to_pay);

    INSERT INTO purchasing.suppliertransactions
        ("SupplierID", "TransactionTypeID", "PurchaseOrderID", "PaymentMethodID",
         "SupplierInvoiceNumber", "TransactionDate", "AmountExcludingTax", "TaxAmount", "TransactionAmount",
         "OutstandingBalance", "FinalizationDate", "LastEditedBy", "LastEditedWhen")
    SELECT ttp.supplier_id, dataloadsimulation.get_transaction_type_id('Supplier Payment Issued'),
           NULL, dataloadsimulation.get_payment_method_id('EFT'),
           NULL, CAST(p_starting_when AS date), 0, 0, 0 - SUM(ttp.outstanding_balance),
           0, CAST(p_starting_when AS date), v_staff_member_person_id, p_starting_when
    FROM transactions_to_pay AS ttp
    GROUP BY ttp.supplier_id;
END;
$$ LANGUAGE plpgsql;
