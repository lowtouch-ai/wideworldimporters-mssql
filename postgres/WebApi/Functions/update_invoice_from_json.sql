-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateInvoiceFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_invoice_from_json(
    p_invoice    text,
    p_invoice_id integer,
    p_user_id    integer
) RETURNS void AS $$
BEGIN
    -- CustomerPurchaseOrderNumber, DeliveryRun, RunPosition: direct (allow NULL)
    -- OrderID in OPENJSON WITH clause but not used in SET — intentionally omitted
    UPDATE sales.invoices
    SET customerid                  = COALESCE(x."CustomerID",              invoices.customerid),
        billtocustomerid            = COALESCE(x."BillToCustomerID",        invoices.billtocustomerid),
        deliverymethodid            = COALESCE(x."DeliveryMethodID",        invoices.deliverymethodid),
        contactpersonid             = COALESCE(x."ContactPersonID",         invoices.contactpersonid),
        accountspersonid            = COALESCE(x."AccountsPersonID",        invoices.accountspersonid),
        salespersonpersonid         = COALESCE(x."SalespersonPersonID",     invoices.salespersonpersonid),
        packedbypersonid            = COALESCE(x."PackedByPersonID",        invoices.packedbypersonid),
        invoicedate                 = COALESCE(x."InvoiceDate",             invoices.invoicedate),
        customerpurchaseordernumber = x."CustomerPurchaseOrderNumber",
        iscreditnote                = COALESCE(x."IsCreditNote",            invoices.iscreditnote),
        totaldryitems               = COALESCE(x."TotalDryItems",           invoices.totaldryitems),
        totalchilleritems           = COALESCE(x."TotalChillerItems",       invoices.totalchilleritems),
        deliveryrun                 = x."DeliveryRun",
        runposition                 = x."RunPosition",
        lasteditedby                = p_user_id
    FROM jsonb_to_record(p_invoice::jsonb) AS x(
        "CustomerID"                  integer,
        "BillToCustomerID"            integer,
        "OrderID"                     integer,
        "DeliveryMethodID"            integer,
        "ContactPersonID"             integer,
        "AccountsPersonID"            integer,
        "SalespersonPersonID"         integer,
        "PackedByPersonID"            integer,
        "InvoiceDate"                 date,
        "CustomerPurchaseOrderNumber" varchar(20),
        "IsCreditNote"                boolean,
        "TotalDryItems"               integer,
        "TotalChillerItems"           integer,
        "DeliveryRun"                 varchar(5),
        "RunPosition"                 varchar(5)
    )
    WHERE invoices.invoiceid = p_invoice_id;
END;
$$ LANGUAGE plpgsql;
