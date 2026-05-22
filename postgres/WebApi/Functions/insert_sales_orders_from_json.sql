CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.insert_sales_orders_from_json(
    p_sales_orders text,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    INSERT INTO sales.orders (
        CustomerID, SalespersonPersonID, ContactPersonID,
        OrderDate, ExpectedDeliveryDate, CustomerPurchaseOrderNumber,
        IsUndersupplyBackordered, Comments, DeliveryInstructions,
        InternalComments, LastEditedBy
    )
    SELECT
        x."CustomerID", x."SalespersonPersonID", x."ContactPersonID",
        x."OrderDate", x."ExpectedDeliveryDate", x."CustomerPurchaseOrderNumber",
        COALESCE(x."IsUndersupplyBackordered", false),
        x."Comments", x."DeliveryInstructions", x."InternalComments",
        p_user_id
    FROM jsonb_to_recordset(
        CASE WHEN jsonb_typeof(p_sales_orders::jsonb) = 'array'
             THEN p_sales_orders::jsonb
             ELSE jsonb_build_array(p_sales_orders::jsonb) END
    ) AS x(
        "CustomerID"                 integer,
        "SalespersonPersonID"        integer,
        "ContactPersonID"            integer,
        "OrderDate"                  date,
        "ExpectedDeliveryDate"       date,
        "CustomerPurchaseOrderNumber" varchar(20),
        "IsUndersupplyBackordered"   boolean,
        "Comments"                   text,
        "DeliveryInstructions"       text,
        "InternalComments"           text
    );
END;
$$ LANGUAGE plpgsql;
