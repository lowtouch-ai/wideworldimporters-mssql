-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/PickStockForCustomerOrders.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.pick_stock_for_customer_orders(
    p_current_date_time timestamp,
    p_starting_when     timestamp,
    p_end_of_time       timestamp,
    p_is_silent_mode    boolean
) RETURNS void AS $$
DECLARE
    v_order_id        integer;
    v_order_line_id   integer;
    v_stock_item_id   integer;
    v_quantity        integer;
    v_available_stock integer;
    v_picking_person_id integer;
    rec               record;
BEGIN
    CREATE TEMP TABLE uninvoiced_orders (
        order_id integer PRIMARY KEY
    ) ON COMMIT DROP;

    INSERT INTO uninvoiced_orders (order_id)
    SELECT o."OrderID"
    FROM sales.orders AS o
    WHERE NOT EXISTS (SELECT 1 FROM sales.invoices AS i WHERE i."OrderID" = o."OrderID");

    CREATE TEMP TABLE stock_already_allocated (
        stock_item_id     integer PRIMARY KEY,
        quantity_allocated integer
    ) ON COMMIT DROP;

    WITH stock_already_alloc AS (
        SELECT ol."StockItemID", SUM(ol."PickedQuantity") AS total_picked_quantity
        FROM sales.orderlines AS ol
        INNER JOIN uninvoiced_orders AS uo ON ol."OrderID" = uo.order_id
        WHERE ol."PickingCompletedWhen" IS NULL
        GROUP BY ol."StockItemID"
    )
    INSERT INTO stock_already_allocated (stock_item_id, quantity_allocated)
    SELECT sa."StockItemID", sa.total_picked_quantity
    FROM stock_already_alloc AS sa;

    v_picking_person_id := dataloadsimulation.get_random_employee_person();

    FOR rec IN
        SELECT ol."OrderID", ol."OrderLineID", ol."StockItemID", ol."Quantity"
        FROM sales.orderlines AS ol
        WHERE ol."PickingCompletedWhen" IS NULL
        ORDER BY ol."OrderID", ol."OrderLineID"
    LOOP
        v_order_id      := rec."OrderID";
        v_order_line_id := rec."OrderLineID";
        v_stock_item_id := rec."StockItemID";
        v_quantity      := rec."Quantity";

        SELECT "QuantityOnHand" INTO v_available_stock
        FROM warehouse.stockitemholdings AS sih
        WHERE sih."StockItemID" = v_stock_item_id;

        v_available_stock := v_available_stock
            - COALESCE((SELECT quantity_allocated FROM stock_already_allocated AS saa
                        WHERE saa.stock_item_id = v_stock_item_id), 0);

        IF v_available_stock >= v_quantity THEN
            -- MERGE on temp table → INSERT ... ON CONFLICT DO UPDATE
            INSERT INTO stock_already_allocated (stock_item_id, quantity_allocated)
            VALUES (v_stock_item_id, v_quantity)
            ON CONFLICT (stock_item_id) DO UPDATE
                SET quantity_allocated = stock_already_allocated.quantity_allocated + EXCLUDED.quantity_allocated;

            UPDATE sales.orderlines
            SET "PickedQuantity"      = v_quantity,
                "PickingCompletedWhen" = p_starting_when,
                "LastEditedBy"        = v_picking_person_id,
                "LastEditedWhen"      = p_starting_when
            WHERE "OrderLineID" = v_order_line_id;

            IF NOT EXISTS (SELECT 1 FROM sales.orderlines AS ol
                           WHERE ol."OrderID" = v_order_id
                             AND ol."PickingCompletedWhen" IS NULL) THEN
                UPDATE sales.orders
                SET "PickingCompletedWhen" = p_starting_when,
                    "PickedByPersonID"     = v_picking_person_id,
                    "LastEditedBy"         = v_picking_person_id,
                    "LastEditedWhen"       = p_starting_when
                WHERE "OrderID" = v_order_id;
            END IF;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
