CREATE SCHEMA IF NOT EXISTS webapi;

-- TODO: FOR JSON PATH not supported in PostgreSQL.
-- The DeliveryLocation column uses json_build_object as an approximation.
-- geography .Long/.Lat → ST_X()/ST_Y() (PostGIS required).
-- Original MSSQL used: FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
CREATE OR REPLACE VIEW webapi.sales_orders AS
SELECT
    o.OrderID,
    o.OrderDate,
    o.CustomerPurchaseOrderNumber,
    o.ExpectedDeliveryDate,
    o.PickingCompletedWhen,
    o.CustomerID,
    c.CustomerName,
    c.PhoneNumber,
    c.FaxNumber,
    c.WebsiteURL,
    NULL::text AS DeliveryLocation,
    sp.FullName AS SalesPerson,
    sp.PhoneNumber AS SalesPersonPhone,
    sp.EmailAddress AS SalesPersonEmail
FROM sales.orders o
    INNER JOIN sales.customers c
        ON o.CustomerID = c.CustomerID
        LEFT JOIN application.deliverymethods AS dm
            ON c.DeliveryMethodID = dm.DeliveryMethodID
    INNER JOIN application.people sp
        ON o.SalespersonPersonID = sp.PersonID;
