# get_customer_updates

Converted from: `wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetCustomerUpdates.sql`

## Summary

Returns a changelog of customer dimension records within a cutoff window, including denormalized category, buying group, contact, and postal code data for DW incremental loads.

## Conversion notes

- `FOR SYSTEM_TIME AS OF` → UNION ALL of `_archive` and current table filtered by ValidFrom/ValidTo range
- MSSQL CURSORs → PL/pgSQL `FOR ... IN SELECT ... LOOP`
- `CREATE TABLE #CustomerChanges` → `CREATE TEMP TABLE _customer_changes ON COMMIT DROP`
- `datetime2(7)` → `timestamp(6)`

## Dependencies

| Object | Status |
|---|---|
| `sales.customers` + `sales.customers_archive` | check postgres/Sales/Tables/ |
| `sales.customercategories` + archive | check postgres/Sales/Tables/ |
| `sales.buyinggroups` + archive | check postgres/Sales/Tables/ |
| `application.people` + archive | check postgres/Application/Tables/ |
