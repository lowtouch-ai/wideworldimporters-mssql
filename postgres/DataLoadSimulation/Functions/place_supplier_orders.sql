-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/PlaceSupplierOrders.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.place_supplier_orders(
    p_current_date_time timestamp,
    p_starting_when     timestamp,
    p_end_of_time       timestamp,
    p_is_silent_mode    boolean
) RETURNS void AS $$
DECLARE
    v_contact_person_id  integer;
    v_supplier_person_id integer;
BEGIN
    v_contact_person_id  := dataloadsimulation.get_random_employee_person();
    v_supplier_person_id := dataloadsimulation.get_random_employee_person();

    CREATE TEMP TABLE orders_to_place (
        supplier_id        integer,
        purchase_order_id  integer,
        delivery_method_id integer,
        contact_person_id  integer,
        supplier_reference varchar(20)
    ) ON COMMIT DROP;

    CREATE TEMP TABLE order_lines_to_place (
        stock_item_id        integer,
        description          varchar(100),
        supplier_id          integer,
        quantity_of_outers   integer,
        lead_time_days       integer,
        outer_package_id     integer,
        last_outer_cost_price numeric(18,2)
    ) ON COMMIT DROP;

    WITH stock_items_to_check AS (
        SELECT si."StockItemID",
               si."StockItemName" AS description,
               si."SupplierID",
               sih."TargetStockLevel",
               sih."ReorderLevel",
               si."QuantityPerOuter",
               si."LeadTimeDays",
               si."OuterPackageID",
               sih."QuantityOnHand",
               sih."LastCostPrice",
               COALESCE((SELECT SUM(ol."Quantity")
                         FROM sales.orderlines AS ol
                         WHERE ol."StockItemID" = si."StockItemID"
                           AND ol."PickingCompletedWhen" IS NULL), 0) AS stock_needed_for_orders,
               COALESCE((SELECT si."QuantityPerOuter" * SUM(pol."OrderedOuters" - pol."ReceivedOuters")
                         FROM purchasing.purchaseorderlines AS pol
                         WHERE pol."StockItemID" = si."StockItemID"
                           AND pol."IsOrderLineFinalized" = false), 0) AS stock_on_order
        FROM warehouse.stockitems AS si
        INNER JOIN warehouse.stockitemholdings AS sih ON si."StockItemID" = sih."StockItemID"
    ),
    stock_items_to_order AS (
        SELECT sitc."StockItemID",
               sitc.description,
               sitc."SupplierID",
               (sitc."QuantityOnHand" + sitc.stock_on_order - sitc.stock_needed_for_orders) AS effective_stock_level,
               sitc."TargetStockLevel",
               sitc."QuantityPerOuter",
               sitc."LeadTimeDays",
               sitc."OuterPackageID",
               sitc."LastCostPrice"
        FROM stock_items_to_check AS sitc
        WHERE (sitc."QuantityOnHand" + sitc.stock_on_order - sitc.stock_needed_for_orders) < sitc."ReorderLevel"
          AND sitc."QuantityPerOuter" <> 0
    )
    INSERT INTO order_lines_to_place
        (stock_item_id, description, supplier_id, quantity_of_outers,
         lead_time_days, outer_package_id, last_outer_cost_price)
    SELECT sito."StockItemID",
           sito.description,
           sito."SupplierID",
           ceil((sito."TargetStockLevel" - sito.effective_stock_level)::numeric / sito."QuantityPerOuter")::integer,
           sito."LeadTimeDays",
           sito."OuterPackageID",
           ROUND(sito."LastCostPrice" * sito."QuantityPerOuter", 2)
    FROM stock_items_to_order AS sito;

    INSERT INTO orders_to_place (supplier_id, purchase_order_id, delivery_method_id, contact_person_id, supplier_reference)
    SELECT s."SupplierID",
           nextval('sequences.purchase_order_id_seq'),
           s."DeliveryMethodID",
           v_supplier_person_id,
           s."SupplierReference"
    FROM purchasing.suppliers AS s
    WHERE s."SupplierID" IN (SELECT supplier_id FROM order_lines_to_place);

    INSERT INTO purchasing.purchaseorders
        ("PurchaseOrderID", "SupplierID", "OrderDate", "DeliveryMethodID", "ContactPersonID",
         "ExpectedDeliveryDate", "SupplierReference", "IsOrderFinalized", "Comments",
         "InternalComments", "LastEditedBy", "LastEditedWhen")
    SELECT o.purchase_order_id, o.supplier_id, CAST(p_starting_when AS date), o.delivery_method_id, o.contact_person_id,
           CAST(p_starting_when AS date) + (SELECT MAX(lead_time_days) FROM order_lines_to_place),
           o.supplier_reference, false, NULL,
           NULL, 1, p_starting_when
    FROM orders_to_place AS o;

    INSERT INTO purchasing.purchaseorderlines
        ("PurchaseOrderID", "StockItemID", "OrderedOuters", "Description",
         "ReceivedOuters", "PackageTypeID", "ExpectedUnitPricePerOuter", "LastReceiptDate",
         "IsOrderLineFinalized", "LastEditedBy", "LastEditedWhen")
    SELECT o.purchase_order_id, ol.stock_item_id, ol.quantity_of_outers, ol.description,
           0, ol.outer_package_id, ol.last_outer_cost_price, NULL,
           false, v_contact_person_id, p_starting_when
    FROM order_lines_to_place AS ol
    INNER JOIN orders_to_place AS o ON ol.supplier_id = o.supplier_id;
END;
$$ LANGUAGE plpgsql;
