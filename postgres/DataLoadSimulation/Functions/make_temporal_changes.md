# Conversion summary: DataLoadSimulation.MakeTemporalChanges

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/MakeTemporalChanges.sql`
- **Pattern:** Simple DML (date-conditional UPDATEs and INSERTs)
- **Output:** `postgres/DataLoadSimulation/Functions/make_temporal_changes.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.make_temporal_changes(p_current_date_time timestamp, p_starting_when timestamp, p_end_of_time timestamp, p_is_silent_mode boolean) RETURNS void
```

## Conversion notes
- `EXTRACT(DAY FROM ...) = 1 AND EXTRACT(MONTH FROM ...) = 7` replaces `DATEPART(day/month, ...)`
- `CAST(p_starting_when AS date) = '2022-01-01'` date comparisons
- `DATEADD(minute, 5, ...)` → `+ interval '5 minutes'`
- `DATEADD(minute, 15, ...)` → `+ interval '15 minutes'`

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `application.cities` | `postgres/Application/Tables/Cities.sql` |
| `application.stateprovinces` | `postgres/Application/Tables/StateProvinces.sql` |
| `application.countries` | `postgres/Application/Tables/Countries.sql` |
| `application.deliverymethods` | `postgres/Application/Tables/DeliveryMethods.sql` |
| `application.paymentmethods` | `postgres/Application/Tables/PaymentMethods.sql` |
| `application.transactiontypes` | `postgres/Application/Tables/TransactionTypes.sql` |
| `warehouse.colors` | `postgres/Warehouse/Tables/Colors.sql` |
| `warehouse.packagetypes` | `postgres/Warehouse/Tables/PackageTypes.sql` |
| `warehouse.stockgroups` | `postgres/Warehouse/Tables/StockGroups.sql` |
| `sales.customers` | `postgres/Sales/Tables/Customers.sql` |
| `sales.customercategories` | `postgres/Sales/Tables/CustomerCategories.sql` |
| `purchasing.suppliercategories` | `postgres/Purchasing/Tables/SupplierCategories.sql` |
