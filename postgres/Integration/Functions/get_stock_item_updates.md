# get_stock_item_updates

Converted from: `wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetStockItemUpdates.sql`

## Summary

Returns a changelog of stock item dimension records within the cutoff window, including denormalized package type and color data for DW incremental loads.

## Conversion notes

- `FOR SYSTEM_TIME AS OF` → UNION ALL of archive + current with ValidFrom/ValidTo range
- MSSQL CURSOR → PL/pgSQL FOR loop
- `ISNULL(Color, N'N/A')` → `COALESCE("Color", 'N/A')`
- `varbinary(max)` → `bytea` for `Photo`
- `bit` → `boolean` for `IsChillerStock`
- `datetime2(7)` → `timestamp(6)`

## Dependencies

| Object | Status |
|---|---|
| `warehouse.stockitems` + `warehouse.stockitems_archive` | check postgres/Warehouse/Tables/ |
| `warehouse.packagetypes` + `warehouse.packagetypes_archive` | check postgres/Warehouse/Tables/ |
| `warehouse.colors` + `warehouse.colors_archive` | check postgres/Warehouse/Tables/ |
