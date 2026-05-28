-- Converted from: wwi-ssdt/wwi-ssdt/Website/Stored Procedures/InsertCustomerOrders.sql
CREATE SCHEMA IF NOT EXISTS website;

CREATE OR REPLACE FUNCTION website.insert_customer_orders(
    p_orders                      website.order_list[],
    p_order_lines                 website.order_line_list[],
    p_orders_created_by_person_id integer,
    p_salesperson_person_id       integer
) RETURNS void AS $$
BEGIN
    -- Allocate new order IDs; stored in temp table so both subsequent INSERTs see the same values.
    DROP TABLE IF EXISTS _orders_to_generate;
    CREATE TEMP TABLE _orders_to_generate (
        orderreference integer PRIMARY KEY,
        orderid        integer NOT NULL
    );

    INSERT INTO _orders_to_generate (orderreference, orderid)
    SELECT o.orderreference, nextval('sequences.order_id_seq')
    FROM UNNEST(p_orders) AS o;

    INSERT INTO sales.orders
        (orderid, customerid, salespersonpersonid, contactpersonid, backorderorderid, orderdate,
         expecteddeliverydate, customerpurchaseordernumber, isundersupplybackordered, comments,
         deliveryinstructions, internalcomments, pickingcompletedwhen, lasteditedby, lasteditedwhen)
    SELECT otg.orderid, o.customerid, p_salesperson_person_id, o.contactpersonid, NULL, CURRENT_DATE,
           o.expecteddeliverydate, o.customerpurchaseordernumber, o.isundersupplybackordered, o.comments,
           o.deliveryinstructions, NULL, NULL, p_orders_created_by_person_id, CURRENT_TIMESTAMP
    FROM _orders_to_generate AS otg
    INNER JOIN UNNEST(p_orders) AS o ON otg.orderreference = o.orderreference;

    INSERT INTO sales.orderlines
        (orderid, stockitemid, description, packagetypeid, quantity, unitprice,
         taxrate, pickedquantity, pickingcompletedwhen, lasteditedby, lasteditedwhen)
    SELECT otg.orderid, ol.stockitemid, ol.description, si.unitpackageid, ol.quantity,
           website.calculate_customer_price(o.customerid, ol.stockitemid, CURRENT_DATE),
           si.taxrate, 0, NULL, p_orders_created_by_person_id, CURRENT_TIMESTAMP
    FROM _orders_to_generate AS otg
    INNER JOIN UNNEST(p_order_lines) AS ol ON otg.orderreference = ol.orderreference
    INNER JOIN UNNEST(p_orders)      AS o  ON ol.orderreference  = o.orderreference
    INNER JOIN warehouse.stockitems  AS si ON ol.stockitemid      = si.stockitemid;

    DROP TABLE IF EXISTS _orders_to_generate;

EXCEPTION WHEN OTHERS THEN
    DROP TABLE IF EXISTS _orders_to_generate;
    RAISE NOTICE 'Unable to create the customer orders.';
    RAISE;
END;
$$ LANGUAGE plpgsql;
