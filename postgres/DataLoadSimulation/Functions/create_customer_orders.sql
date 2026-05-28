-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/CreateCustomerOrders.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.create_customer_orders(
    p_current_date_time          timestamp,
    p_starting_when              timestamp,
    p_end_of_time                timestamp,
    p_number_of_customer_orders  integer,
    p_is_silent_mode             boolean
) RETURNS void AS $$
DECLARE
    v_order_counter            integer := 0;
    v_order_line_counter       integer := 0;
    v_customer_id              integer;
    v_order_id                 bigint;
    v_primary_contact_person_id integer;
    v_salesperson_person_id    integer;
    v_expected_delivery_date   date;
    v_order_date_time          timestamp;
    v_number_of_order_lines    integer;
    v_stock_item_id            integer;
    v_stock_item_name          varchar(100);
    v_unit_package_id          integer;
    v_quantity_per_outer       integer;
    v_quantity                 integer;
    v_customer_price           numeric(18,2);
    v_tax_rate                 numeric(18,3);
BEGIN
    v_expected_delivery_date := CAST(p_current_date_time AS date) + 1;
    v_order_date_time        := p_starting_when;

    -- No deliveries on weekends (PostgreSQL DOW: 0=Sunday, 6=Saturday)
    WHILE EXTRACT(DOW FROM v_expected_delivery_date) IN (0, 6) LOOP
        v_expected_delivery_date := v_expected_delivery_date + 1;
    END LOOP;

    WHILE v_order_counter < p_number_of_customer_orders LOOP
        v_order_id := nextval('sequences.order_id_seq');

        SELECT random_customer_id, customer_primary_contact_person_id
        INTO v_customer_id, v_primary_contact_person_id
        FROM dataloadsimulation.get_random_customer();

        v_salesperson_person_id := dataloadsimulation.get_random_sales_person_id();

        INSERT INTO sales.orders
            ("OrderID", "CustomerID", "SalespersonPersonID", "PickedByPersonID", "ContactPersonID",
             "BackorderOrderID", "OrderDate", "ExpectedDeliveryDate", "CustomerPurchaseOrderNumber",
             "IsUndersupplyBackordered", "Comments", "DeliveryInstructions", "InternalComments",
             "PickingCompletedWhen", "LastEditedBy", "LastEditedWhen")
        VALUES
            (v_order_id, v_customer_id, v_salesperson_person_id, NULL, v_primary_contact_person_id,
             NULL, p_current_date_time, v_expected_delivery_date,
             CAST(ceil(random() * 10000)::integer + 10000 AS varchar(20)),
             true, NULL, NULL, NULL,
             NULL, 1, v_order_date_time);

        v_number_of_order_lines := 1 + ceil(random() * 4)::integer;
        v_order_line_counter    := 0;

        WHILE v_order_line_counter < v_number_of_order_lines LOOP
            SELECT si."StockItemID", si."StockItemName", si."UnitPackageID",
                   si."QuantityPerOuter", si."TaxRate"
            INTO v_stock_item_id, v_stock_item_name, v_unit_package_id,
                 v_quantity_per_outer, v_tax_rate
            FROM warehouse.stockitems AS si
            WHERE NOT EXISTS (SELECT 1 FROM sales.orderlines AS ol
                              WHERE ol."OrderID" = v_order_id
                                AND ol."StockItemID" = si."StockItemID")
            ORDER BY random() LIMIT 1;

            v_quantity       := v_quantity_per_outer * (1 + floor(random() * 10)::integer);
            v_customer_price := website.calculate_customer_price(v_customer_id, v_stock_item_id, p_current_date_time);

            INSERT INTO sales.orderlines
                ("OrderID", "StockItemID", "Description", "PackageTypeID", "Quantity", "UnitPrice",
                 "TaxRate", "PickedQuantity", "PickingCompletedWhen", "LastEditedBy", "LastEditedWhen")
            VALUES
                (v_order_id, v_stock_item_id, v_stock_item_name, v_unit_package_id, v_quantity, v_customer_price,
                 v_tax_rate, 0, NULL, 1, p_starting_when);

            v_order_line_counter := v_order_line_counter + 1;
        END LOOP;

        v_order_counter := v_order_counter + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
