-- Converted from: wwi-ssdt/wwi-ssdt/Website/Functions/CalculateCustomerPrice.sql
CREATE SCHEMA IF NOT EXISTS website;

CREATE OR REPLACE FUNCTION website.calculate_customer_price(
    p_customer_id   integer,
    p_stock_item_id integer,
    p_pricing_date  date
) RETURNS numeric(18, 2) AS $$
DECLARE
    _calculated_price        numeric(18, 2);
    _unit_price              numeric(18, 2);
    _lowest_unit_price       numeric(18, 2);
    _highest_discount_amount numeric(18, 2);
    _highest_discount_pct    numeric(18, 3);
    _buying_group_id         integer;
    _customer_category_id    integer;
    _discounted_unit_price   numeric(18, 2);
BEGIN
    SELECT BuyingGroupID, CustomerCategoryID
    INTO _buying_group_id, _customer_category_id
    FROM sales.customers
    WHERE CustomerID = p_customer_id;

    SELECT UnitPrice INTO _unit_price
    FROM warehouse.stockitems AS si
    WHERE si.StockItemID = p_stock_item_id;

    _calculated_price := _unit_price;

    SELECT MIN(sd.UnitPrice) INTO _lowest_unit_price
    FROM sales.specialdeals AS sd
    WHERE ((sd.StockItemID = p_stock_item_id) OR (sd.StockItemID IS NULL))
      AND ((sd.CustomerID = p_customer_id) OR (sd.CustomerID IS NULL))
      AND ((sd.BuyingGroupID = _buying_group_id) OR (sd.BuyingGroupID IS NULL))
      AND ((sd.CustomerCategoryID = _customer_category_id) OR (sd.CustomerCategoryID IS NULL))
      AND ((sd.StockGroupID IS NULL) OR EXISTS (
               SELECT 1 FROM warehouse.stockitemstockgroups AS sisg
               WHERE sisg.StockItemID = p_stock_item_id
                 AND sisg.StockGroupID = sd.StockGroupID))
      AND sd.UnitPrice IS NOT NULL
      AND p_pricing_date BETWEEN sd.StartDate AND sd.EndDate;

    IF _lowest_unit_price IS NOT NULL AND _lowest_unit_price < _unit_price THEN
        _calculated_price := _lowest_unit_price;
    END IF;

    SELECT MAX(sd.DiscountAmount) INTO _highest_discount_amount
    FROM sales.specialdeals AS sd
    WHERE ((sd.StockItemID = p_stock_item_id) OR (sd.StockItemID IS NULL))
      AND ((sd.CustomerID = p_customer_id) OR (sd.CustomerID IS NULL))
      AND ((sd.BuyingGroupID = _buying_group_id) OR (sd.BuyingGroupID IS NULL))
      AND ((sd.CustomerCategoryID = _customer_category_id) OR (sd.CustomerCategoryID IS NULL))
      AND ((sd.StockGroupID IS NULL) OR EXISTS (
               SELECT 1 FROM warehouse.stockitemstockgroups AS sisg
               WHERE sisg.StockItemID = p_stock_item_id
                 AND sisg.StockGroupID = sd.StockGroupID))
      AND sd.DiscountAmount IS NOT NULL
      AND p_pricing_date BETWEEN sd.StartDate AND sd.EndDate;

    IF _highest_discount_amount IS NOT NULL AND (_unit_price - _highest_discount_amount) < _calculated_price THEN
        _calculated_price := _unit_price - _highest_discount_amount;
    END IF;

    SELECT MAX(sd.DiscountPercentage) INTO _highest_discount_pct
    FROM sales.specialdeals AS sd
    WHERE ((sd.StockItemID = p_stock_item_id) OR (sd.StockItemID IS NULL))
      AND ((sd.CustomerID = p_customer_id) OR (sd.CustomerID IS NULL))
      AND ((sd.BuyingGroupID = _buying_group_id) OR (sd.BuyingGroupID IS NULL))
      AND ((sd.CustomerCategoryID = _customer_category_id) OR (sd.CustomerCategoryID IS NULL))
      AND ((sd.StockGroupID IS NULL) OR EXISTS (
               SELECT 1 FROM warehouse.stockitemstockgroups AS sisg
               WHERE sisg.StockItemID = p_stock_item_id
                 AND sisg.StockGroupID = sd.StockGroupID))
      AND sd.DiscountPercentage IS NOT NULL
      AND p_pricing_date BETWEEN sd.StartDate AND sd.EndDate;

    IF _highest_discount_pct IS NOT NULL THEN
        _discounted_unit_price := ROUND(_unit_price * _highest_discount_pct / 100.0, 2);
        IF _discounted_unit_price < _calculated_price THEN
            _calculated_price := _discounted_unit_price;
        END IF;
    END IF;

    RETURN _calculated_price;
END;
$$ LANGUAGE plpgsql;
