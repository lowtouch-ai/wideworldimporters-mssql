CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.insert_invoices_from_json(
    p_invoices text,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    INSERT INTO sales.invoices (
        CustomerID, BillToCustomerID, OrderID, DeliveryMethodID,
        ContactPersonID, AccountsPersonID, SalespersonPersonID, PackedByPersonID,
        InvoiceDate, CustomerPurchaseOrderNumber, IsCreditNote, CreditNoteReason,
        Comments, DeliveryInstructions, InternalComments,
        TotalDryItems, TotalChillerItems, DeliveryRun, RunPosition,
        ReturnedDeliveryData, ConfirmedDeliveryTime, ConfirmedReceivedBy,
        LastEditedBy
    )
    SELECT
        x."CustomerID", COALESCE(x."BillToCustomerID", x."CustomerID"),
        x."OrderID", x."DeliveryMethodID",
        x."ContactPersonID", x."AccountsPersonID", x."SalespersonPersonID",
        x."PackedByPersonID", x."InvoiceDate", x."CustomerPurchaseOrderNumber",
        COALESCE(x."IsCreditNote", false), x."CreditNoteReason",
        x."Comments", x."DeliveryInstructions", x."InternalComments",
        COALESCE(x."TotalDryItems", 0), COALESCE(x."TotalChillerItems", 0),
        x."DeliveryRun", x."RunPosition",
        x."ReturnedDeliveryData", x."ConfirmedDeliveryTime", x."ConfirmedReceivedBy",
        p_user_id
    FROM jsonb_to_recordset(
        CASE WHEN jsonb_typeof(p_invoices::jsonb) = 'array'
             THEN p_invoices::jsonb
             ELSE jsonb_build_array(p_invoices::jsonb) END
    ) AS x(
        "CustomerID"                 integer,
        "BillToCustomerID"           integer,
        "OrderID"                    integer,
        "DeliveryMethodID"           integer,
        "ContactPersonID"            integer,
        "AccountsPersonID"           integer,
        "SalespersonPersonID"        integer,
        "PackedByPersonID"           integer,
        "InvoiceDate"                date,
        "CustomerPurchaseOrderNumber" varchar(20),
        "IsCreditNote"               boolean,
        "CreditNoteReason"           text,
        "Comments"                   text,
        "DeliveryInstructions"       text,
        "InternalComments"           text,
        "TotalDryItems"              integer,
        "TotalChillerItems"          integer,
        "DeliveryRun"                varchar(5),
        "RunPosition"                varchar(5),
        "ReturnedDeliveryData"       text,
        "ConfirmedDeliveryTime"      timestamp,
        "ConfirmedReceivedBy"        text
    );
END;
$$ LANGUAGE plpgsql;
