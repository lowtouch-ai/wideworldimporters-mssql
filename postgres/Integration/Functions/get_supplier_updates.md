# get_supplier_updates

Converted from: `wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetSupplierUpdates.sql`

## Summary

Returns a changelog of supplier dimension records within the cutoff window, including denormalized category and contact data for DW incremental loads.

## Conversion notes

- `FOR SYSTEM_TIME AS OF` → UNION ALL of archive + current with ValidFrom/ValidTo range
- MSSQL CURSOR → PL/pgSQL FOR loop
- `datetime2(7)` → `timestamp(6)`

## Dependencies

| Object | Status |
|---|---|
| `purchasing.suppliers` + `purchasing.suppliers_archive` | check postgres/Purchasing/Tables/ |
| `purchasing.suppliercategories` + archive | check postgres/Purchasing/Tables/ |
| `application.people` + archive | check postgres/Application/Tables/ |
