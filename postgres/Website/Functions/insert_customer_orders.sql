-- Converted from: wwi-ssdt/wwi-ssdt/Website/Stored Procedures/InsertCustomerOrders.sql
CREATE SCHEMA IF NOT EXISTS website;

-- NOTE: MSSQL TVP parameters @Orders (Website.OrderList) and @OrderLines (Website.OrderLineList)
-- are replaced with JSONB parameters. Callers must pass JSON arrays.
-- TODO: Consider using the converted composite types in postgres/Website/Types/ if available,
--       or accept jsonb and use jsonb_to_recordset() to unpack.

CREATE OR REPLACE FUNCTION website.insert_customer_orders(
    p_Orders jsonb,
    p_OrderLines jsonb,
    p_OrdersCreatedByPersonID integer,
    p_SalespersonPersonID integer
) RETURNS void AS $$
DECLARE
    -- Temporary table to hold order reference → new OrderID mappings
    -- Using a CTE/temp approach inline
BEGIN
    -- Allocate new order IDs and insert orders
    -- MSSQL: INSERT @OrdersToGenerate using NEXT VALUE FOR Sequences.OrderID
    -- PostgreSQL: use nextval('sequences.order_id_seq') per row via a temp table

    CREATE TEMP TABLE _orders_to_generate (
        OrderReference integer PRIMARY KEY,
        OrderID integer
    ) ON COMMIT DROP;

    INSERT INTO _orders_to_generate (OrderReference, OrderID)
    SELECT (o->>'OrderReference')::integer,
           nextval('sequences.order_id_seq')
    FROM jsonb_array_elements(p_Orders) AS o;

    INSERT INTO sales.orders
        (OrderID, CustomerID, SalespersonPersonID, PickedByPersonID, ContactPersonID,
         BackorderOrderID, OrderDate, ExpectedDeliveryDate, CustomerPurchaseOrderNumber,
         IsUndersupplyBackordered, Comments, DeliveryInstructions, InternalComments,
         PickingCompletedWhen, LastEditedBy, LastEditedWhen)
    SELECT otg.OrderID,
           (o->>'CustomerID')::integer,
           p_SalespersonPersonID,
           NULL,
           (o->>'ContactPersonID')::integer,
           NULL,
           CURRENT_TIMESTAMP,
           (o->>'ExpectedDeliveryDate')::date,
           o->>'CustomerPurchaseOrderNumber',
           (o->>'IsUndersupplyBackordered')::boolean,
           o->>'Comments',
           o->>'DeliveryInstructions',
           NULL,
           NULL,
           p_OrdersCreatedByPersonID,
           CURRENT_TIMESTAMP
    FROM _orders_to_generate AS otg
    JOIN jsonb_array_elements(p_Orders) AS o
      ON otg.OrderReference = (o->>'OrderReference')::integer;

    INSERT INTO sales.orderlines
        (OrderID, StockItemID, Description, PackageTypeID, Quantity, UnitPrice,
         TaxRate, PickedQuantity, PickingCompletedWhen, LastEditedBy, LastEditedWhen)
    SELECT otg.OrderID,
           (ol->>'StockItemID')::integer,
           ol->>'Description',
           si.UnitPackageID,
           (ol->>'Quantity')::integer,
           website.calculate_customer_price(
               (o->>'CustomerID')::integer,
               (ol->>'StockItemID')::integer,
               CURRENT_TIMESTAMP::date
           ),
           si.TaxRate,
           0,
           NULL,
           p_OrdersCreatedByPersonID,
           CURRENT_TIMESTAMP
    FROM _orders_to_generate AS otg
    JOIN jsonb_array_elements(p_OrderLines) AS ol
      ON otg.OrderReference = (ol->>'OrderReference')::integer
    JOIN jsonb_array_elements(p_Orders) AS o
      ON (ol->>'OrderReference')::integer = (o->>'OrderReference')::integer
    JOIN warehouse.stockitems AS si
      ON (ol->>'StockItemID')::integer = si.StockItemID;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Unable to create the customer orders.';
        RAISE;
END;
$$ LANGUAGE plpgsql;
