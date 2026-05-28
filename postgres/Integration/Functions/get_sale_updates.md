# get_sale_updates

Converted from: `wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetSaleUpdates.sql`

## Summary

Returns invoice and invoice line records modified within the cutoff window for DW incremental loads.

## Conversion notes

- Straightforward SELECT; converted to `RETURNS TABLE` + `RETURN QUERY`
- `INNER JOIN` → `JOIN`
- `IsChillerStock = 0` → `IsChillerStock = false`, `IsChillerStock <> 0` → `IsChillerStock`
- `datetime2(7)` → `timestamp(6)`
- `decimal(18,2)` → `numeric(18,2)`

## Dependencies

| Object | Status |
|---|---|
| `sales.invoices` | check postgres/Sales/Tables/Invoices.sql |
| `sales.invoicelines` | check postgres/Sales/Tables/InvoiceLines.sql |
| `warehouse.stockitems` | check postgres/Warehouse/Tables/StockItems.sql |
| `warehouse.packagetypes` | check postgres/Warehouse/Tables/PackageTypes.sql |
| `sales.customers` | check postgres/Sales/Tables/Customers.sql |
