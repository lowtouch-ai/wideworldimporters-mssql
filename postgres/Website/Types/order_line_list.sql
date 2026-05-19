-- Converted from: wwi-ssdt/wwi-ssdt/Website/User Defined Types/OrderLineList.sql
CREATE SCHEMA IF NOT EXISTS website;

-- Re-run: DROP TYPE IF EXISTS website.order_line_list; before applying if type already exists.
CREATE TYPE website.order_line_list AS (
    OrderReference integer,
    StockItemID    integer,
    Description    varchar(100),
    Quantity       integer
);
