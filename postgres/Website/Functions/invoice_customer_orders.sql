-- Converted from: wwi-ssdt/wwi-ssdt/Website/Stored Procedures/InvoiceCustomerOrders.sql
CREATE SCHEMA IF NOT EXISTS website;

CREATE OR REPLACE FUNCTION website.invoice_customer_orders(
    p_orders_to_invoice   website.order_id_list[],
    p_packed_by_person_id integer,
    p_invoiced_by_person_id integer
) RETURNS void AS $$
DECLARE
    v_stock_issue_type_id   integer;
    v_customer_invoice_type_id integer;
BEGIN
    DROP TABLE IF EXISTS _invoices_to_generate;
    CREATE TEMP TABLE _invoices_to_generate (
        orderid           integer PRIMARY KEY,
        invoiceid         integer NOT NULL,
        totaldryitems     integer NOT NULL,
        totalchilleritems integer NOT NULL
    );

    -- Allocate invoice numbers for all orders that exist, are fully picked, and not yet invoiced
    INSERT INTO _invoices_to_generate (orderid, invoiceid, totaldryitems, totalchilleritems)
    SELECT oti.orderid,
           nextval('sequences.invoice_id_seq'),
           COALESCE((SELECT SUM(CASE WHEN si.ischillerstock THEN 0 ELSE 1 END)
                     FROM sales.orderlines AS ol
                     INNER JOIN warehouse.stockitems AS si ON ol.stockitemid = si.stockitemid
                     WHERE ol.orderid = oti.orderid), 0),
           COALESCE((SELECT SUM(CASE WHEN si.ischillerstock THEN 1 ELSE 0 END)
                     FROM sales.orderlines AS ol
                     INNER JOIN warehouse.stockitems AS si ON ol.stockitemid = si.stockitemid
                     WHERE ol.orderid = oti.orderid), 0)
    FROM UNNEST(p_orders_to_invoice) AS oti
    INNER JOIN sales.orders AS o ON oti.orderid = o.orderid
    WHERE NOT EXISTS (SELECT 1 FROM sales.invoices AS i WHERE i.orderid = oti.orderid)
      AND o.pickingcompletedwhen IS NOT NULL;

    IF EXISTS (
        SELECT 1 FROM UNNEST(p_orders_to_invoice) AS oti
        WHERE NOT EXISTS (SELECT 1 FROM _invoices_to_generate AS itg WHERE itg.orderid = oti.orderid)
    ) THEN
        RAISE NOTICE 'At least one order ID either does not exist, is not picked, or is already invoiced';
        RAISE EXCEPTION 'At least one orderID either does not exist, is not picked, or is already invoiced';
    END IF;

    SELECT transactiontypeid INTO v_stock_issue_type_id
    FROM application.transaction_types WHERE transactiontypename = 'Stock Issue';

    SELECT transactiontypeid INTO v_customer_invoice_type_id
    FROM application.transaction_types WHERE transactiontypename = 'Customer Invoice';

    INSERT INTO sales.invoices
        (invoiceid, customerid, billtocustomerid, orderid, deliverymethodid, contactpersonid, accountspersonid,
         salespersonpersonid, packedbypersonid, invoicedate, customerpurchaseordernumber,
         iscreditnote, creditnotereason, comments, deliveryinstructions, internalcomments,
         totaldryitems, totalchilleritems, deliveryrun, runposition,
         returneddeliverydata,
         lasteditedby, lasteditedwhen)
    SELECT itg.invoiceid, c.customerid, c.billtocustomerid, itg.orderid, c.deliverymethodid, o.contactpersonid, btc.primarycontactpersonid,
           o.salespersonpersonid, p_packed_by_person_id, CURRENT_DATE, o.customerpurchaseordernumber,
           false, NULL, NULL,
           c.deliveryaddressline1 || ', ' || COALESCE(c.deliveryaddressline2, ''),
           NULL,
           itg.totaldryitems, itg.totalchilleritems, c.deliveryrun, c.runposition,
           -- TODO: JSON_MODIFY chain → jsonb construction; verify shape matches original ReturnedDeliveryData
           jsonb_build_object(
               'Events', jsonb_build_array(
                   jsonb_build_object(
                       'Event',     'Ready for collection',
                       'EventTime', to_char(CURRENT_TIMESTAMP, 'YYYY-MM-DD"T"HH24:MI:SS'),
                       'ConNote',   'EAN-125-' || (itg.invoiceid + 1050)::text
                   )
               )
           )::text,
           p_invoiced_by_person_id, CURRENT_TIMESTAMP
    FROM _invoices_to_generate AS itg
    INNER JOIN sales.orders AS o ON itg.orderid = o.orderid
    INNER JOIN sales.customers AS c ON o.customerid = c.customerid
    INNER JOIN sales.customers AS btc ON btc.customerid = c.billtocustomerid;

    INSERT INTO sales.invoicelines
        (invoiceid, stockitemid, description, packagetypeid,
         quantity, unitprice, taxrate, taxamount, lineprofit, extendedprice,
         lasteditedby, lasteditedwhen)
    SELECT itg.invoiceid, ol.stockitemid, ol.description, ol.packagetypeid,
           ol.pickedquantity, ol.unitprice, ol.taxrate,
           ROUND(ol.pickedquantity * ol.unitprice * ol.taxrate / 100.0, 2),
           ROUND(ol.pickedquantity * (ol.unitprice - sih.lastcostprice), 2),
           ROUND(ol.pickedquantity * ol.unitprice, 2)
             + ROUND(ol.pickedquantity * ol.unitprice * ol.taxrate / 100.0, 2),
           p_invoiced_by_person_id, CURRENT_TIMESTAMP
    FROM _invoices_to_generate AS itg
    INNER JOIN sales.orderlines AS ol ON itg.orderid = ol.orderid
    INNER JOIN warehouse.stockitems AS si ON ol.stockitemid = si.stockitemid
    INNER JOIN warehouse.stockitemholdings AS sih ON si.stockitemid = sih.stockitemid
    ORDER BY ol.orderid, ol.orderlineid;

    INSERT INTO warehouse.stockitemtransactions
        (stockitemid, transactiontypeid, customerid, invoiceid, supplierid, purchaseorderid,
         transactionoccurredwhen, quantity, lasteditedby, lasteditedwhen)
    SELECT il.stockitemid, v_stock_issue_type_id,
           i.customerid, i.invoiceid, NULL, NULL,
           CURRENT_TIMESTAMP, 0 - il.quantity, p_invoiced_by_person_id, CURRENT_TIMESTAMP
    FROM _invoices_to_generate AS itg
    INNER JOIN sales.invoicelines AS il ON itg.invoiceid = il.invoiceid
    INNER JOIN sales.invoices AS i ON il.invoiceid = i.invoiceid
    ORDER BY il.invoiceid, il.invoicelineid;

    UPDATE warehouse.stockitemholdings AS sih
    SET quantityonhand = sih.quantityonhand - sit.totalquantity,
        lasteditedby   = p_invoiced_by_person_id,
        lasteditedwhen = CURRENT_TIMESTAMP
    FROM (
        SELECT il.stockitemid, SUM(il.quantity) AS totalquantity
        FROM sales.invoicelines AS il
        WHERE il.invoiceid IN (SELECT invoiceid FROM _invoices_to_generate)
        GROUP BY il.stockitemid
    ) AS sit
    WHERE sih.stockitemid = sit.stockitemid;

    INSERT INTO sales.customertransactions
        (customerid, transactiontypeid, invoiceid, paymentmethodid,
         transactiondate, amountexcludingtax, taxamount, transactionamount,
         outstandingbalance, finalizationdate, lasteditedby, lasteditedwhen)
    SELECT i.billtocustomerid,
           v_customer_invoice_type_id,
           itg.invoiceid,
           NULL,
           CURRENT_DATE,
           (SELECT SUM(il.extendedprice - il.taxamount) FROM sales.invoicelines AS il WHERE il.invoiceid = itg.invoiceid),
           (SELECT SUM(il.taxamount) FROM sales.invoicelines AS il WHERE il.invoiceid = itg.invoiceid),
           (SELECT SUM(il.extendedprice) FROM sales.invoicelines AS il WHERE il.invoiceid = itg.invoiceid),
           (SELECT SUM(il.extendedprice) FROM sales.invoicelines AS il WHERE il.invoiceid = itg.invoiceid),
           NULL,
           p_invoiced_by_person_id,
           CURRENT_TIMESTAMP
    FROM _invoices_to_generate AS itg
    INNER JOIN sales.invoices AS i ON itg.invoiceid = i.invoiceid;

    DROP TABLE IF EXISTS _invoices_to_generate;

EXCEPTION WHEN OTHERS THEN
    DROP TABLE IF EXISTS _invoices_to_generate;
    RAISE NOTICE 'Unable to invoice these orders';
    RAISE;
END;
$$ LANGUAGE plpgsql;
