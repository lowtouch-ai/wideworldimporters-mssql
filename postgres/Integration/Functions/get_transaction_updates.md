# get_transaction_updates

Converted from: `wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetTransactionUpdates.sql`

## Summary

Returns a unified changelog of both customer and supplier transactions modified within the cutoff window for DW incremental loads. No temporal tables — straightforward UNION ALL SELECT.

## Conversion notes

- `LEFT OUTER JOIN` → `LEFT JOIN`
- `CAST(NULL AS nvarchar(20))` → `CAST(NULL AS varchar(20))`
- `bit` → `boolean` for `IsFinalized`
- `datetime2(7)` → `timestamp(6)`
- `decimal(18,2)` → `numeric(18,2)`

## Dependencies

| Object | Status |
|---|---|
| `sales.customertransactions` | check postgres/Sales/Tables/CustomerTransactions.sql |
| `sales.invoices` | check postgres/Sales/Tables/Invoices.sql |
| `purchasing.suppliertransactions` | check postgres/Purchasing/Tables/SupplierTransactions.sql |
