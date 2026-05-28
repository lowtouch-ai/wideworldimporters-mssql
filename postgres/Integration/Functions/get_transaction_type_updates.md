# get_transaction_type_updates

Converted from: `wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetTransactionTypeUpdates.sql`

## Summary

Returns a changelog of transaction type records within the cutoff window for DW incremental loads.

## Conversion notes

- `FOR SYSTEM_TIME AS OF` → UNION ALL of archive + current with ValidFrom/ValidTo range
- MSSQL CURSOR → PL/pgSQL FOR loop
- `datetime2(7)` → `timestamp(6)`

## Dependencies

| Object | Status |
|---|---|
| `application.transactiontypes` + `application.transactiontypes_archive` | check postgres/Application/Tables/ |
