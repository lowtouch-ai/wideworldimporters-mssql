# get_order_updates

Converted from: `wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetOrderUpdates.sql`

## Summary

Returns order and order line records modified within the cutoff window for DW incremental loads.

## Conversion notes

- Straightforward SELECT; converted to `RETURNS TABLE` + `RETURN QUERY`
- `INNER JOIN` → `JOIN`
- `datetime2(7)` → `timestamp(6)`
- `decimal(18,2)` → `numeric(18,2)`

## Dependencies

| Object | Status |
|---|---|
| `sales.orders` | check postgres/Sales/Tables/Orders.sql |
| `sales.orderlines` | check postgres/Sales/Tables/OrderLines.sql |
| `warehouse.packagetypes` | check postgres/Warehouse/Tables/PackageTypes.sql |
| `sales.customers` | check postgres/Sales/Tables/Customers.sql |
