-- Converted from: wwi-ssdt/wwi-ssdt/Website/User Defined Types/OrderIDList.sql
CREATE SCHEMA IF NOT EXISTS website;

-- Re-run: DROP TYPE IF EXISTS website.order_id_list; before applying if type already exists.
CREATE TYPE website.order_id_list AS (
    OrderID integer
);
