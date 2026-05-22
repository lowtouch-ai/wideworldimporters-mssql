-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/InvoicePickedOrders.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.invoice_picked_orders(
    p_current_date_time timestamp,
    p_starting_when     timestamp,
    p_end_of_time       timestamp,
    p_is_silent_mode    boolean
) RETURNS void AS $$
DECLARE
    v_invoicing_person_id  integer;
    v_packed_by_person_id  integer;
    v_order_id             integer;
    v_invoice_id           bigint;
    v_picking_completed_when timestamp;
    v_backorder_order_id   bigint;
    v_bill_to_customer_id  integer;
    v_total_dry_items      integer;
    v_total_chiller_items  integer;
    v_transaction_amount   numeric(18,2);
    v_tax_amount           numeric(18,2);
    v_returned_delivery_data jsonb;
    v_delivery_event       jsonb;
    rec                    record;
BEGIN
    v_invoicing_person_id := dataloadsimulation.get_random_employee_person();
    v_packed_by_person_id := dataloadsimulation.get_random_employee_person();

    FOR rec IN
        SELECT o."OrderID", o."PickingCompletedWhen", c."BillToCustomerID"
        FROM sales.orders AS o
        INNER JOIN sales.customers AS c ON o."CustomerID" = c."CustomerID"
        WHERE NOT EXISTS (SELECT 1 FROM sales.invoices AS i WHERE i."OrderID" = o."OrderID")
          AND c."IsOnCreditHold" = false
          AND ((o."PickingCompletedWhen" IS NOT NULL)
               OR (o."PickingCompletedWhen" IS NULL
                   AND o."IsUndersupplyBackordered" <> false
                   AND EXISTS (SELECT 1 FROM sales.orderlines AS ol
                               WHERE ol."OrderID" = o."OrderID"
                                 AND ol."PickingCompletedWhen" IS NOT NULL)))
    LOOP
        v_order_id               := rec."OrderID";
        v_picking_completed_when := rec."PickingCompletedWhen";
        v_bill_to_customer_id    := rec."BillToCustomerID";

        IF v_picking_completed_when IS NULL THEN
            v_backorder_order_id     := nextval('sequences.order_id_seq');
            v_picking_completed_when := p_starting_when;

            INSERT INTO sales.orders
                ("OrderID", "CustomerID", "SalespersonPersonID", "PickedByPersonID", "ContactPersonID",
                 "BackorderOrderID", "OrderDate", "ExpectedDeliveryDate", "CustomerPurchaseOrderNumber",
                 "IsUndersupplyBackordered", "Comments", "DeliveryInstructions", "InternalComments",
                 "PickingCompletedWhen", "LastEditedBy", "LastEditedWhen")
            SELECT v_backorder_order_id, o."CustomerID", o."SalespersonPersonID", NULL, o."ContactPersonID", NULL,
                   o."OrderDate", o."ExpectedDeliveryDate", o."CustomerPurchaseOrderNumber", true,
                   o."Comments", o."DeliveryInstructions", o."InternalComments", NULL,
                   v_invoicing_person_id, p_starting_when
            FROM sales.orders AS o
            WHERE o."OrderID" = v_order_id;

            UPDATE sales.orderlines
            SET "OrderID"        = v_backorder_order_id,
                "LastEditedBy"   = v_invoicing_person_id,
                "LastEditedWhen" = p_starting_when
            WHERE "OrderID" = v_order_id
              AND "PickingCompletedWhen" IS NULL;

            UPDATE sales.orders
            SET "BackorderOrderID"    = v_backorder_order_id,
                "PickingCompletedWhen" = v_picking_completed_when,
                "LastEditedBy"        = v_invoicing_person_id,
                "LastEditedWhen"      = p_starting_when
            WHERE "OrderID" = v_order_id;
        END IF;

        SELECT SUM(CASE WHEN si."IsChillerStock" <> false THEN 0 ELSE 1 END),
               SUM(CASE WHEN si."IsChillerStock" <> false THEN 1 ELSE 0 END)
        INTO v_total_dry_items, v_total_chiller_items
        FROM sales.orderlines AS ol
        INNER JOIN warehouse.stockitems AS si ON ol."StockItemID" = si."StockItemID"
        WHERE ol."OrderID" = v_order_id;

        v_invoice_id := nextval('sequences.invoice_id_seq');

        v_returned_delivery_data := '{"Events": []}'::jsonb;
        v_delivery_event         := '{}'::jsonb;

        v_delivery_event := jsonb_set(v_delivery_event, '{Event}',     '"Ready for collection"');
        v_delivery_event := jsonb_set(v_delivery_event, '{EventTime}', to_json(to_char(p_starting_when, 'YYYY-MM-DD"T"HH24:MI:SS'))::jsonb);
        v_delivery_event := jsonb_set(v_delivery_event, '{ConNote}',   to_json('EAN-125-' || (v_invoice_id + 1050)::varchar)::jsonb);

        v_returned_delivery_data := jsonb_set(
            v_returned_delivery_data, '{Events}',
            (v_returned_delivery_data->'Events') || jsonb_build_array(v_delivery_event)
        );

        INSERT INTO sales.invoices
            ("InvoiceID", "CustomerID", "BillToCustomerID", "OrderID", "DeliveryMethodID",
             "ContactPersonID", "AccountsPersonID", "SalespersonPersonID", "PackedByPersonID",
             "InvoiceDate", "CustomerPurchaseOrderNumber", "IsCreditNote", "CreditNoteReason",
             "Comments", "DeliveryInstructions", "InternalComments",
             "TotalDryItems", "TotalChillerItems",
             "DeliveryRun", "RunPosition", "ReturnedDeliveryData", "LastEditedBy", "LastEditedWhen")
        SELECT v_invoice_id, c."CustomerID", v_bill_to_customer_id, v_order_id, c."DeliveryMethodID",
               o."ContactPersonID", btc."PrimaryContactPersonID",
               o."SalespersonPersonID", v_packed_by_person_id,
               p_starting_when, o."CustomerPurchaseOrderNumber",
               false, NULL, NULL,
               c."DeliveryAddressLine1" || ', ' || COALESCE(c."DeliveryAddressLine2", ''), NULL,
               v_total_dry_items, v_total_chiller_items,
               c."DeliveryRun", c."RunPosition", v_returned_delivery_data::text,
               v_invoicing_person_id, p_starting_when
        FROM sales.orders AS o
        INNER JOIN sales.customers AS c   ON o."CustomerID" = c."CustomerID"
        INNER JOIN sales.customers AS btc ON btc."CustomerID" = c."BillToCustomerID"
        WHERE o."OrderID" = v_order_id;

        INSERT INTO sales.invoicelines
            ("InvoiceID", "StockItemID", "Description", "PackageTypeID",
             "Quantity", "UnitPrice", "TaxRate", "TaxAmount", "LineProfit", "ExtendedPrice",
             "LastEditedBy", "LastEditedWhen")
        SELECT v_invoice_id, ol."StockItemID", ol."Description", ol."PackageTypeID",
               ol."PickedQuantity", ol."UnitPrice", ol."TaxRate",
               ROUND(ol."PickedQuantity" * ol."UnitPrice" * ol."TaxRate" / 100.0, 2),
               ROUND(ol."PickedQuantity" * (ol."UnitPrice" - sih."LastCostPrice"), 2),
               ROUND(ol."PickedQuantity" * ol."UnitPrice", 2)
                 + ROUND(ol."PickedQuantity" * ol."UnitPrice" * ol."TaxRate" / 100.0, 2),
               v_invoicing_person_id, p_starting_when
        FROM sales.orderlines AS ol
        INNER JOIN warehouse.stockitems AS si       ON ol."StockItemID" = si."StockItemID"
        INNER JOIN warehouse.stockitemholdings AS sih ON si."StockItemID" = sih."StockItemID"
        WHERE ol."OrderID" = v_order_id
        ORDER BY ol."OrderLineID";

        INSERT INTO warehouse.stockitemtransactions
            ("StockItemID", "TransactionTypeID", "CustomerID", "InvoiceID", "SupplierID", "PurchaseOrderID",
             "TransactionOccurredWhen", "Quantity", "LastEditedBy", "LastEditedWhen")
        SELECT il."StockItemID",
               dataloadsimulation.get_transaction_type_id('Stock Issue'),
               i."CustomerID", i."InvoiceID", NULL, NULL,
               p_starting_when, 0 - il."Quantity", v_invoicing_person_id, p_starting_when
        FROM sales.invoicelines AS il
        INNER JOIN sales.invoices AS i ON il."InvoiceID" = i."InvoiceID"
        WHERE i."InvoiceID" = v_invoice_id
        ORDER BY il."InvoiceLineID";

        WITH stock_item_totals AS (
            SELECT il."StockItemID", SUM(il."Quantity") AS total_quantity
            FROM sales.invoicelines AS il
            WHERE il."InvoiceID" = v_invoice_id
            GROUP BY il."StockItemID"
        )
        UPDATE warehouse.stockitemholdings AS sih
        SET "QuantityOnHand" = sih."QuantityOnHand" - sit.total_quantity,
            "LastEditedBy"   = v_invoicing_person_id,
            "LastEditedWhen" = p_starting_when
        FROM stock_item_totals AS sit
        WHERE sih."StockItemID" = sit."StockItemID";

        SELECT SUM(il."ExtendedPrice"), SUM(il."TaxAmount")
        INTO v_transaction_amount, v_tax_amount
        FROM sales.invoicelines AS il
        WHERE il."InvoiceID" = v_invoice_id;

        INSERT INTO sales.customertransactions
            ("CustomerID", "TransactionTypeID", "InvoiceID", "PaymentMethodID",
             "TransactionDate", "AmountExcludingTax", "TaxAmount", "TransactionAmount",
             "OutstandingBalance", "FinalizationDate", "LastEditedBy", "LastEditedWhen")
        VALUES
            (v_bill_to_customer_id,
             dataloadsimulation.get_transaction_type_id('Customer Invoice'),
             v_invoice_id, NULL,
             p_starting_when, v_transaction_amount - v_tax_amount, v_tax_amount, v_transaction_amount,
             v_transaction_amount, NULL, v_invoicing_person_id, p_starting_when);
    END LOOP;
END;
$$ LANGUAGE plpgsql;
