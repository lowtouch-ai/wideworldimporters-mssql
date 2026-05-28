DO $body$
BEGIN
IF (SELECT COUNT(*) FROM purchasing.purchaseorderlines) = 0 THEN

-- Stock items 1-3 have confirmed non-NULL ColorIDs; the purchase_order_lines view
-- uses INNER JOIN warehouse.colors which would silently drop rows with NULL ColorID.
INSERT INTO purchasing.purchaseorderlines
  (PurchaseOrderLineID, PurchaseOrderID, StockItemID, OrderedOuters, Description,
   ReceivedOuters, PackageTypeID, ExpectedUnitPricePerOuter, LastReceiptDate,
   IsOrderLineFinalized, LastEditedBy)
VALUES
  (1,  1, 1,  50,  'USB missile launcher (Green)',  50,  7, 25.00, '2020-01-19', false, 1)
, (2,  1, 2,  30,  'USB rocket launcher (Gray)',    30,  7, 25.00, '2020-01-19', false, 1)
, (3,  2, 3,  20,  'Office cube periscope (Black)', 20,  6, 18.50, '2020-01-24', true,  1)
, (4,  2, 1,  100, 'USB missile launcher (Green)',  100, 7, 25.00, '2020-01-24', true,  1)
, (5,  3, 2,  80,  'USB rocket launcher (Gray)',    40,  7, 25.00, NULL,         false, 1)
, (6,  3, 3,  60,  'Office cube periscope (Black)', 60,  6, 18.50, '2020-02-17', false, 1)
, (7,  4, 1,  40,  'USB missile launcher (Green)',  40,  7, 25.00, '2020-02-28', true,  1)
, (8,  4, 2,  10,  'USB rocket launcher (Gray)',    10,  7, 25.00, '2020-02-28', true,  1)
, (9,  5, 3,  75,  'Office cube periscope (Black)', 0,   6, 18.50, NULL,         false, 1)
, (10, 5, 1,  75,  'USB missile launcher (Green)',  0,   7, 25.00, NULL,         false, 1)
, (11, 6, 1,  200, 'USB missile launcher (Green)',  200, 7, 23.00, '2020-04-03', true,  1)
, (12, 6, 2,  150, 'USB rocket launcher (Gray)',    150, 7, 23.00, '2020-04-03', true,  1)
;

END IF;
END;
$body$;
