# get_purchase_updates

Converted from: `wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetPurchaseUpdates.sql`

## Summary

Returns purchase order line records modified within the cutoff window for DW incremental loads.

## Conversion notes

- Straightforward SELECT; converted to `RETURNS TABLE` + `RETURN QUERY`
- `INNER JOIN` → `JOIN`
- `bit` → `boolean` for `IsOrderLineFinalized`
- `datetime2(7)` → `timestamp(6)`

## Dependencies

| Object | Status |
|---|---|
| `purchasing.purchaseorders` | check postgres/Purchasing/Tables/PurchaseOrders.sql |
| `purchasing.purchaseorderlines` | check postgres/Purchasing/Tables/PurchaseOrderLines.sql |
| `warehouse.stockitems` | check postgres/Warehouse/Tables/StockItems.sql |
| `warehouse.packagetypes` | check postgres/Warehouse/Tables/PackageTypes.sql |
