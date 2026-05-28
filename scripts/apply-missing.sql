-- =============================================================================
-- apply-missing.sql
-- Applies functions and seed data missing from the branch.
-- Safe to re-run:
--   • Functions use CREATE OR REPLACE — existing ones are updated, not dropped.
--   • Seed inserts are wrapped in IF COUNT(*) = 0 — skipped if data exists.
--   • No existing data is removed or modified.
-- Run with: psql -U postgres -d postgres -f scripts/apply-missing.sql
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. WebApi functions
-- ---------------------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.delete_purchase_order(
    p_purchase_order_id integer
) RETURNS void AS $$
BEGIN
    DELETE FROM purchasing.purchaseorders
    WHERE PurchaseOrderID = p_purchase_order_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION webapi.delete_purchase_order_line(
    p_purchase_order_line_id integer
) RETURNS void AS $$
BEGIN
    DELETE FROM purchasing.purchaseorderlines
    WHERE PurchaseOrderLineID = p_purchase_order_line_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION webapi.delete_supplier_transaction(
    p_supplier_transaction_id integer
) RETURNS void AS $$
BEGIN
    DELETE FROM purchasing.suppliertransactions
    WHERE SupplierTransactionID = p_supplier_transaction_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION webapi.insert_purchase_orders_from_json(
    p_purchase_orders text,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    INSERT INTO purchasing.purchaseorders (
        SupplierID, OrderDate, DeliveryMethodID, ContactPersonID,
        ExpectedDeliveryDate, SupplierReference, IsOrderFinalized, Comments,
        InternalComments, LastEditedBy
    )
    SELECT
        x."SupplierID", x."OrderDate", x."DeliveryMethodID", x."ContactPersonID",
        x."ExpectedDeliveryDate", x."SupplierReference", x."IsOrderFinalized",
        x."Comments", x."InternalComments", p_user_id
    FROM jsonb_to_recordset(
        CASE WHEN jsonb_typeof(p_purchase_orders::jsonb) = 'array'
             THEN p_purchase_orders::jsonb
             ELSE jsonb_build_array(p_purchase_orders::jsonb) END
    ) AS x(
        "SupplierID"           integer,
        "OrderDate"            date,
        "DeliveryMethodID"     integer,
        "ContactPersonID"      integer,
        "ExpectedDeliveryDate" date,
        "SupplierReference"    varchar(20),
        "IsOrderFinalized"     boolean,
        "Comments"             text,
        "InternalComments"     text
    );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION webapi.insert_purchase_order_lines_from_json(
    p_purchase_order_lines text,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    INSERT INTO purchasing.purchaseorderlines (
        PurchaseOrderID, StockItemID, OrderedOuters, Description, ReceivedOuters,
        PackageTypeID, ExpectedUnitPricePerOuter, LastReceiptDate,
        IsOrderLineFinalized, LastEditedBy
    )
    SELECT
        x."PurchaseOrderID", x."StockItemID", x."OrderedOuters", x."Description",
        COALESCE(x."ReceivedOuters", 0), x."PackageTypeID",
        x."ExpectedUnitPricePerOuter", x."LastReceiptDate",
        COALESCE(x."IsOrderLineFinalized", false), p_user_id
    FROM jsonb_to_recordset(
        CASE WHEN jsonb_typeof(p_purchase_order_lines::jsonb) = 'array'
             THEN p_purchase_order_lines::jsonb
             ELSE jsonb_build_array(p_purchase_order_lines::jsonb) END
    ) AS x(
        "PurchaseOrderID"           integer,
        "StockItemID"               integer,
        "OrderedOuters"             integer,
        "Description"               varchar(100),
        "ReceivedOuters"            integer,
        "PackageTypeID"             integer,
        "ExpectedUnitPricePerOuter" numeric(18,2),
        "LastReceiptDate"           date,
        "IsOrderLineFinalized"      boolean
    );
END;
$$ LANGUAGE plpgsql;

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

CREATE OR REPLACE FUNCTION webapi.update_purchase_order_line_from_json(
    p_purchase_order_line text,
    p_purchase_order_line_id integer,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    UPDATE purchasing.purchaseorderlines SET
        PurchaseOrderID           = COALESCE(json."PurchaseOrderID", purchasing.purchaseorderlines.PurchaseOrderID),
        StockItemID               = COALESCE(json."StockItemID", purchasing.purchaseorderlines.StockItemID),
        OrderedOuters             = COALESCE(json."OrderedOuters", purchasing.purchaseorderlines.OrderedOuters),
        Description               = COALESCE(json."Description", purchasing.purchaseorderlines.Description),
        ReceivedOuters            = COALESCE(json."ReceivedOuters", purchasing.purchaseorderlines.ReceivedOuters),
        PackageTypeID             = COALESCE(json."PackageTypeID", purchasing.purchaseorderlines.PackageTypeID),
        ExpectedUnitPricePerOuter = COALESCE(json."ExpectedUnitPricePerOuter", purchasing.purchaseorderlines.ExpectedUnitPricePerOuter),
        LastReceiptDate           = json."LastReceiptDate",
        IsOrderLineFinalized      = COALESCE(json."IsOrderLineFinalized", purchasing.purchaseorderlines.IsOrderLineFinalized),
        LastEditedBy              = p_user_id
    FROM jsonb_to_record(p_purchase_order_line::jsonb) AS json(
        "PurchaseOrderID"           integer,
        "StockItemID"               integer,
        "OrderedOuters"             integer,
        "Description"               varchar(100),
        "ReceivedOuters"            integer,
        "PackageTypeID"             integer,
        "ExpectedUnitPricePerOuter" numeric(18,2),
        "LastReceiptDate"           date,
        "IsOrderLineFinalized"      boolean
    )
    WHERE PurchaseOrderLineID = p_purchase_order_line_id;
END;
$$ LANGUAGE plpgsql;

-- ---------------------------------------------------------------------------
-- 2. Seed data — each block skipped if the table already has rows
-- ---------------------------------------------------------------------------

DO $body$
BEGIN
IF (SELECT COUNT(*) FROM purchasing.purchaseorders) = 0 THEN

INSERT INTO purchasing.purchaseorders
  (PurchaseOrderID, SupplierID, OrderDate, DeliveryMethodID, ContactPersonID,
   ExpectedDeliveryDate, SupplierReference, IsOrderFinalized, Comments, LastEditedBy)
VALUES
  (1, 1, '2020-01-05', 2, 1, '2020-01-19', 'REF-A001', false, NULL, 1)
, (2, 2, '2020-01-10', 1, 1, '2020-01-24', 'REF-B002', true,  NULL, 1)
, (3, 3, '2020-02-03', 3, 1, '2020-02-17', 'REF-C003', false, NULL, 1)
, (4, 4, '2020-02-14', 2, 1, '2020-02-28', 'REF-D004', true,  NULL, 1)
, (5, 5, '2020-03-01', 1, 1, '2020-03-15', 'REF-E005', false, NULL, 1)
, (6, 6, '2020-03-20', 3, 1, '2020-04-03', 'REF-F006', true,  NULL, 1)
;

END IF;
END;
$body$;

DO $body$
BEGIN
IF (SELECT COUNT(*) FROM purchasing.purchaseorderlines) = 0 THEN

INSERT INTO purchasing.purchaseorderlines
  (PurchaseOrderLineID, PurchaseOrderID, StockItemID, OrderedOuters, Description,
   ReceivedOuters, PackageTypeID, ExpectedUnitPricePerOuter, LastReceiptDate,
   IsOrderLineFinalized, LastEditedBy)
VALUES
  (1,  1, 1,  50,  'USB missile launcher (Green)',  50,  7, 25.00, '2020-01-19', false, 1)
, (2,  1, 2,  30,  'USB rocket launcher (Gray)',    30,  7, 25.00, '2020-01-19', false, 1)
, (3,  2, 3,  20,  'Office cube periscope (Black)', 20,  6, 18.50, '2020-01-24', true,  1)
, (4,  2, 1,  100, 'USB missile launcher (Green)',  100, 7, 25.00, '2020-01-24', true,  1)
, (5,  3, 2,  80,  'USB rocket launcher (Gray)',    40,  7, 25.00, NULL,         false, 1)
, (6,  3, 3,  60,  'Office cube periscope (Black)', 60,  6, 18.50, '2020-02-17', false, 1)
, (7,  4, 1,  40,  'USB missile launcher (Green)',  40,  7, 25.00, '2020-02-28', true,  1)
, (8,  4, 2,  10,  'USB rocket launcher (Gray)',    10,  7, 25.00, '2020-02-28', true,  1)
, (9,  5, 3,  75,  'Office cube periscope (Black)', 0,   6, 18.50, NULL,         false, 1)
, (10, 5, 1,  75,  'USB missile launcher (Green)',  0,   7, 25.00, NULL,         false, 1)
, (11, 6, 1,  200, 'USB missile launcher (Green)',  200, 7, 23.00, '2020-04-03', true,  1)
, (12, 6, 2,  150, 'USB rocket launcher (Gray)',    150, 7, 23.00, '2020-04-03', true,  1)
;

END IF;
END;
$body$;

DO $body$
BEGIN
IF (SELECT COUNT(*) FROM purchasing.suppliertransactions) = 0 THEN

INSERT INTO purchasing.suppliertransactions
  (SupplierTransactionID, SupplierID, TransactionTypeID, PurchaseOrderID, PaymentMethodID,
   SupplierInvoiceNumber, TransactionDate, AmountExcludingTax, TaxAmount,
   TransactionAmount, OutstandingBalance, FinalizationDate, LastEditedBy)
VALUES
  (1, 1, 5, 1, NULL, 'INV-A001', '2020-01-19', 1375.00, 137.50, 1512.50, 1512.50, NULL,         1)
, (2, 2, 5, 2, NULL, 'INV-B002', '2020-01-24',  740.00,  74.00,  814.00,    0.00, '2020-02-05', 1)
, (3, 2, 7, 2, 4,    NULL,       '2020-02-05',  814.00,   0.00,  814.00,    0.00, '2020-02-05', 1)
, (4, 3, 5, 3, NULL, 'INV-C003', '2020-02-17', 2288.00, 228.80, 2516.80, 2516.80, NULL,         1)
, (5, 4, 5, 4, NULL, 'INV-D004', '2020-02-28', 3680.00, 368.00, 4048.00,    0.00, '2020-03-10', 1)
, (6, 4, 7, 4, 4,    NULL,       '2020-03-10', 4048.00,   0.00, 4048.00,    0.00, '2020-03-10', 1)
, (7, 5, 5, 5, NULL, 'INV-E005', '2020-03-15', 4800.00, 480.00, 5280.00, 5280.00, NULL,         1)
, (8, 6, 5, 6, NULL, 'INV-F006', '2020-04-03', 8050.00, 805.00, 8855.00,    0.00, '2020-04-15', 1)
, (9, 6, 7, 6, 1,    NULL,       '2020-04-15', 8855.00,   0.00, 8855.00,    0.00, '2020-04-15', 1)
;

END IF;
END;
$body$;
