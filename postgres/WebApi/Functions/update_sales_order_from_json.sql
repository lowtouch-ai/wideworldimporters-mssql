-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateSalesOrderFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_sales_order_from_json(
    p_sales_order text,
    p_sales_order_id integer,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    UPDATE sales.orders SET
        SalespersonPersonID = COALESCE(json.SalespersonPersonID, sales.orders.SalespersonPersonID),
        PickedByPersonID = COALESCE(json.PickedByPersonID, sales.orders.PickedByPersonID),
        ContactPersonID = COALESCE(json.ContactPersonID, sales.orders.ContactPersonID),
        BackorderOrderID = COALESCE(json.BackorderOrderID, sales.orders.BackorderOrderID),
        OrderDate = COALESCE(json.OrderDate, sales.orders.OrderDate),
        ExpectedDeliveryDate = COALESCE(json.ExpectedDeliveryDate, sales.orders.ExpectedDeliveryDate),
        CustomerPurchaseOrderNumber = COALESCE(json.CustomerPurchaseOrderNumber, sales.orders.CustomerPurchaseOrderNumber),
        IsUndersupplyBackordered = COALESCE(json.IsUndersupplyBackordered, sales.orders.IsUndersupplyBackordered),
        PickingCompletedWhen = COALESCE(json.PickingCompletedWhen, sales.orders.PickingCompletedWhen),
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_sales_order::jsonb) AS json(
        SalespersonPersonID integer,
        PickedByPersonID integer,
        ContactPersonID integer,
        BackorderOrderID integer,
        OrderDate date,
        ExpectedDeliveryDate date,
        CustomerPurchaseOrderNumber varchar(20),
        IsUndersupplyBackordered boolean,
        PickingCompletedWhen date
    )
    WHERE OrderID = p_sales_order_id;
END;
$$ LANGUAGE plpgsql;
