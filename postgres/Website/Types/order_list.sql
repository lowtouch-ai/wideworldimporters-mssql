-- Converted from: wwi-ssdt/wwi-ssdt/Website/User Defined Types/OrderList.sql
CREATE SCHEMA IF NOT EXISTS website;

-- Re-run: DROP TYPE IF EXISTS website.order_list; before applying if type already exists.
CREATE TYPE website.order_list AS (
    OrderReference              integer,
    CustomerID                  integer,
    ContactPersonID             integer,
    ExpectedDeliveryDate        date,
    CustomerPurchaseOrderNumber varchar(20),
    IsUndersupplyBackordered    boolean,
    Comments                    text,
    DeliveryInstructions        text
);
