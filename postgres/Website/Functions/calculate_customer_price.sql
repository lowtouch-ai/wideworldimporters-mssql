-- Converted from: wwi-ssdt/wwi-ssdt/Website/Functions/CalculateCustomerPrice.sql
CREATE SCHEMA IF NOT EXISTS website;

CREATE OR REPLACE FUNCTION website.calculate_customer_price(
    p_CustomerID integer,
    p_StockItemID integer,
    p_PricingDate date
) RETURNS numeric(18,2) AS $$
DECLARE
    _CalculatedPrice numeric(18,2);
    _UnitPrice numeric(18,2);
    _LowestUnitPrice numeric(18,2);
    _HighestDiscountAmount numeric(18,2);
    _HighestDiscountPercentage numeric(18,3);
    _BuyingGroupID integer;
    _CustomerCategoryID integer;
    _DiscountedUnitPrice numeric(18,2);
BEGIN
    SELECT BuyingGroupID, CustomerCategoryID
    INTO _BuyingGroupID, _CustomerCategoryID
    FROM sales.customers
    WHERE CustomerID = p_CustomerID;

    SELECT si.UnitPrice
    INTO _UnitPrice
    FROM warehouse.stockitems AS si
    WHERE si.StockItemID = p_StockItemID;

    _CalculatedPrice := _UnitPrice;

    SELECT MIN(sd.UnitPrice)
    INTO _LowestUnitPrice
    FROM sales.specialdeals AS sd
    WHERE ((sd.StockItemID = p_StockItemID) OR (sd.StockItemID IS NULL))
    AND ((sd.CustomerID = p_CustomerID) OR (sd.CustomerID IS NULL))
    AND ((sd.BuyingGroupID = _BuyingGroupID) OR (sd.BuyingGroupID IS NULL))
    AND ((sd.CustomerCategoryID = _CustomerCategoryID) OR (sd.CustomerCategoryID IS NULL))
    AND ((sd.StockGroupID IS NULL) OR EXISTS (SELECT 1 FROM warehouse.stockitemstockgroups AS sisg
                                               WHERE sisg.StockItemID = p_StockItemID
                                               AND sisg.StockGroupID = sd.StockGroupID))
    AND sd.UnitPrice IS NOT NULL
    AND p_PricingDate BETWEEN sd.StartDate AND sd.EndDate;

    IF _LowestUnitPrice IS NOT NULL AND _LowestUnitPrice < _UnitPrice THEN
        _CalculatedPrice := _LowestUnitPrice;
    END IF;

    SELECT MAX(sd.DiscountAmount)
    INTO _HighestDiscountAmount
    FROM sales.specialdeals AS sd
    WHERE ((sd.StockItemID = p_StockItemID) OR (sd.StockItemID IS NULL))
    AND ((sd.CustomerID = p_CustomerID) OR (sd.CustomerID IS NULL))
    AND ((sd.BuyingGroupID = _BuyingGroupID) OR (sd.BuyingGroupID IS NULL))
    AND ((sd.CustomerCategoryID = _CustomerCategoryID) OR (sd.CustomerCategoryID IS NULL))
    AND ((sd.StockGroupID IS NULL) OR EXISTS (SELECT 1 FROM warehouse.stockitemstockgroups AS sisg
                                               WHERE sisg.StockItemID = p_StockItemID
                                               AND sisg.StockGroupID = sd.StockGroupID))
    AND sd.DiscountAmount IS NOT NULL
    AND p_PricingDate BETWEEN sd.StartDate AND sd.EndDate;

    IF _HighestDiscountAmount IS NOT NULL AND (_UnitPrice - _HighestDiscountAmount) < _CalculatedPrice THEN
        _CalculatedPrice := _UnitPrice - _HighestDiscountAmount;
    END IF;

    SELECT MAX(sd.DiscountPercentage)
    INTO _HighestDiscountPercentage
    FROM sales.specialdeals AS sd
    WHERE ((sd.StockItemID = p_StockItemID) OR (sd.StockItemID IS NULL))
    AND ((sd.CustomerID = p_CustomerID) OR (sd.CustomerID IS NULL))
    AND ((sd.BuyingGroupID = _BuyingGroupID) OR (sd.BuyingGroupID IS NULL))
    AND ((sd.CustomerCategoryID = _CustomerCategoryID) OR (sd.CustomerCategoryID IS NULL))
    AND ((sd.StockGroupID IS NULL) OR EXISTS (SELECT 1 FROM warehouse.stockitemstockgroups AS sisg
                                               WHERE sisg.StockItemID = p_StockItemID
                                               AND sisg.StockGroupID = sd.StockGroupID))
    AND sd.DiscountPercentage IS NOT NULL
    AND p_PricingDate BETWEEN sd.StartDate AND sd.EndDate;

    IF _HighestDiscountPercentage IS NOT NULL THEN
        _DiscountedUnitPrice := ROUND(_UnitPrice * _HighestDiscountPercentage / 100.0, 2);
        IF _DiscountedUnitPrice < _CalculatedPrice THEN
            _CalculatedPrice := _DiscountedUnitPrice;
        END IF;
    END IF;

    RETURN _CalculatedPrice;
END;
$$ LANGUAGE plpgsql;
