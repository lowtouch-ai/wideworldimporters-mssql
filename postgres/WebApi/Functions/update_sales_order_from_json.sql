-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateSalesOrderFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_sales_order_from_json(
    p_sales_order    text,
    p_sales_order_id integer,
    p_user_id        integer
) RETURNS void AS $$
BEGIN
    UPDATE sales.orders
    SET salespersonpersonid         = COALESCE(x."SalespersonPersonID",         orders.salespersonpersonid),
        pickedbypersonid            = COALESCE(x."PickedByPersonID",            orders.pickedbypersonid),
        contactpersonid             = COALESCE(x."ContactPersonID",             orders.contactpersonid),
        backorderorderid            = COALESCE(x."BackorderOrderID",            orders.backorderorderid),
        orderdate                   = COALESCE(x."OrderDate",                   orders.orderdate),
        expecteddeliverydate        = COALESCE(x."ExpectedDeliveryDate",        orders.expecteddeliverydate),
        customerpurchaseordernumber = COALESCE(x."CustomerPurchaseOrderNumber", orders.customerpurchaseordernumber),
        isundersupplybackordered    = COALESCE(x."IsUndersupplyBackordered",    orders.isundersupplybackordered),
        pickingcompletedwhen        = COALESCE(x."PickingCompletedWhen",        orders.pickingcompletedwhen),
        lasteditedby                = p_user_id
    FROM jsonb_to_record(p_sales_order::jsonb) AS x(
        "SalespersonPersonID"         integer,
        "PickedByPersonID"            integer,
        "ContactPersonID"             integer,
        "BackorderOrderID"            integer,
        "OrderDate"                   date,
        "ExpectedDeliveryDate"        date,
        "CustomerPurchaseOrderNumber" varchar(20),
        "IsUndersupplyBackordered"    boolean,
        "PickingCompletedWhen"        date
    )
    WHERE orders.orderid = p_sales_order_id;
END;
$$ LANGUAGE plpgsql;
