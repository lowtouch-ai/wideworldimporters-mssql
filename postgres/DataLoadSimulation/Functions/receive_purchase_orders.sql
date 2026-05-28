-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/ReceivePurchaseOrders.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.receive_purchase_orders(
    p_current_date_time timestamp,
    p_starting_when     timestamp,
    p_end_of_time       timestamp,
    p_is_silent_mode    boolean
) RETURNS void AS $$
DECLARE
    v_staff_member_person_id integer;
    v_total_excluding_tax    numeric(18,2);
    v_total_including_tax    numeric(18,2);
    rec                      record;
BEGIN
    SELECT "PersonID" INTO v_staff_member_person_id
    FROM application.people
    WHERE "IsEmployee" <> false
    ORDER BY random() LIMIT 1;

    FOR rec IN
        SELECT "PurchaseOrderID", "SupplierID"
        FROM purchasing.purchaseorders AS po
        WHERE po."IsOrderFinalized" = false
          AND po."ExpectedDeliveryDate" >= p_starting_when
    LOOP
        UPDATE purchasing.purchaseorderlines
        SET "ReceivedOuters"      = "OrderedOuters",
            "IsOrderLineFinalized" = true,
            "LastReceiptDate"     = CAST(p_starting_when AS date),
            "LastEditedBy"        = v_staff_member_person_id,
            "LastEditedWhen"      = p_starting_when
        WHERE "PurchaseOrderID" = rec."PurchaseOrderID";

        UPDATE warehouse.stockitemholdings AS sih
        SET "QuantityOnHand" = sih."QuantityOnHand" + pol."ReceivedOuters" * si."QuantityPerOuter",
            "LastEditedBy"   = v_staff_member_person_id,
            "LastEditedWhen" = p_starting_when
        FROM purchasing.purchaseorderlines AS pol
        INNER JOIN warehouse.stockitems AS si ON sih."StockItemID" = si."StockItemID"
        WHERE sih."StockItemID" = pol."StockItemID"
          AND pol."PurchaseOrderID" = rec."PurchaseOrderID";

        INSERT INTO warehouse.stockitemtransactions
            ("StockItemID", "TransactionTypeID", "CustomerID", "InvoiceID", "SupplierID", "PurchaseOrderID",
             "TransactionOccurredWhen", "Quantity", "LastEditedBy", "LastEditedWhen")
        SELECT pol."StockItemID",
               (SELECT "TransactionTypeID" FROM application.transactiontypes WHERE "TransactionTypeName" = 'Stock Receipt'),
               NULL, NULL, rec."SupplierID", pol."PurchaseOrderID",
               p_starting_when, pol."ReceivedOuters" * si."QuantityPerOuter",
               v_staff_member_person_id, p_starting_when
        FROM purchasing.purchaseorderlines AS pol
        INNER JOIN warehouse.stockitems AS si ON pol."StockItemID" = si."StockItemID"
        WHERE pol."PurchaseOrderID" = rec."PurchaseOrderID";

        UPDATE purchasing.purchaseorders
        SET "IsOrderFinalized" = true,
            "LastEditedBy"     = v_staff_member_person_id,
            "LastEditedWhen"   = p_starting_when
        WHERE "PurchaseOrderID" = rec."PurchaseOrderID";

        SELECT SUM(ROUND(pol."OrderedOuters" * pol."ExpectedUnitPricePerOuter", 2)),
               SUM(ROUND(pol."OrderedOuters" * pol."ExpectedUnitPricePerOuter", 2))
                 + SUM(ROUND(pol."OrderedOuters" * pol."ExpectedUnitPricePerOuter" * si."TaxRate" / 100.0, 2))
        INTO v_total_excluding_tax, v_total_including_tax
        FROM purchasing.purchaseorderlines AS pol
        INNER JOIN warehouse.stockitems AS si ON pol."StockItemID" = si."StockItemID"
        WHERE pol."PurchaseOrderID" = rec."PurchaseOrderID";

        INSERT INTO purchasing.suppliertransactions
            ("SupplierID", "TransactionTypeID", "PurchaseOrderID", "PaymentMethodID",
             "SupplierInvoiceNumber", "TransactionDate", "AmountExcludingTax",
             "TaxAmount", "TransactionAmount", "OutstandingBalance",
             "FinalizationDate", "LastEditedBy", "LastEditedWhen")
        VALUES
            (rec."SupplierID",
             (SELECT "TransactionTypeID" FROM application.transactiontypes WHERE "TransactionTypeName" = 'Supplier Invoice'),
             rec."PurchaseOrderID",
             (SELECT "PaymentMethodID" FROM application.paymentmethods WHERE "PaymentMethodName" = 'EFT'),
             CAST(ceil(random() * 10000)::integer AS varchar(20)),
             CAST(p_starting_when AS date),
             v_total_excluding_tax,
             v_total_including_tax - v_total_excluding_tax,
             v_total_including_tax,
             v_total_including_tax,
             NULL, v_staff_member_person_id, p_starting_when);
    END LOOP;
END;
$$ LANGUAGE plpgsql;
