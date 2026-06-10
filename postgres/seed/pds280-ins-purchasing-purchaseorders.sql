DO $body$
BEGIN
IF (SELECT COUNT(*) FROM purchasing.purchaseorders) = 0 THEN

INSERT INTO purchasing.purchaseorders
  (PurchaseOrderID, SupplierID, OrderDate, DeliveryMethodID, ContactPersonID,
   ExpectedDeliveryDate, SupplierReference, IsOrderFinalized, Comments, LastEditedBy)
VALUES
  (1, 1, '2020-01-05', 2, 1, '2020-01-19', 'REF-A001', false, NULL, 1)
, (2, 2, '2020-01-10', 1, 1, '2020-01-24', 'REF-B002', true,  NULL, 1)
, (3, 3, '2020-02-03', 3, 1, '2020-02-17', 'REF-C003', false, NULL, 1)
, (4, 4, '2020-02-14', 2, 1, '2020-02-28', 'REF-D004', true,  NULL, 1)
, (5, 5, '2020-03-01', 1, 1, '2020-03-15', 'REF-E005', false, NULL, 1)
, (6, 6, '2020-03-20', 3, 1, '2020-04-03', 'REF-F006', true,  NULL, 1)
;

END IF;
END;
$body$;
