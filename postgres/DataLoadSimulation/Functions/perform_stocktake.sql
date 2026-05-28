-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/PerformStocktake.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.perform_stocktake(
    p_current_date_time timestamp,
    p_starting_when     timestamp,
    p_end_of_time       timestamp,
    p_is_silent_mode    boolean
) RETURNS void AS $$
DECLARE
    v_staff_member_person_id   integer;
    v_counter                  integer := 0;
    v_number_of_adjusted_items integer;
    v_stock_item_id_to_adjust  integer;
    v_quantity_to_adjust       integer;
BEGIN
    v_staff_member_person_id := dataloadsimulation.get_random_employee_person();

    v_number_of_adjusted_items := ceil(random() * 5)::integer;

    UPDATE warehouse.stockitemholdings
    SET "LastStocktakeQuantity" = "QuantityOnHand",
        "LastEditedBy"          = v_staff_member_person_id,
        "LastEditedWhen"        = p_starting_when;

    WHILE v_counter < v_number_of_adjusted_items LOOP
        v_quantity_to_adjust := (5 - ceil(random() * 10)::integer);
        v_stock_item_id_to_adjust := dataloadsimulation.get_random_stock_item_to_adjust(v_quantity_to_adjust);

        IF v_stock_item_id_to_adjust IS NOT NULL THEN
            UPDATE warehouse.stockitemholdings
            SET "LastStocktakeQuantity" = "LastStocktakeQuantity" + v_quantity_to_adjust,
                "LastEditedBy"          = v_staff_member_person_id,
                "LastEditedWhen"        = p_starting_when
            WHERE "StockItemID" = v_stock_item_id_to_adjust;

            INSERT INTO warehouse.stockitemtransactions
                ("StockItemID", "TransactionTypeID", "CustomerID", "InvoiceID", "SupplierID", "PurchaseOrderID",
                 "TransactionOccurredWhen", "Quantity", "LastEditedBy", "LastEditedWhen")
            VALUES
                (v_stock_item_id_to_adjust,
                 dataloadsimulation.get_transaction_type_id('Stock Adjustment at Stocktake'),
                 NULL, NULL, NULL, NULL,
                 p_starting_when, v_quantity_to_adjust, v_staff_member_person_id, p_starting_when);
        END IF;

        v_counter := v_counter + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
