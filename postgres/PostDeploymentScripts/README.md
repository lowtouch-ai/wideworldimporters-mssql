# PostDeploymentScripts — PostgreSQL

Seed data scripts converted from `wwi-ssdt/wwi-ssdt/PostDeploymentScripts/`. Run after all schema DDL and functions are deployed.

## Prerequisites

- PostgreSQL 15+ with PostGIS extension (`CREATE EXTENSION IF NOT EXISTS postgis;`)
- All schema DDL deployed (`postgres/<Schema>/Tables/`)
- All functions deployed (`postgres/<Schema>/Functions/`, `postgres/Sequences/Functions/`)

## Running

```bash
psql -U postgres -d wideworldimporters -f script_post_deployment1.sql
```

The orchestrator runs all scripts in dependency order. It must be invoked from the `postgres/PostDeploymentScripts/` directory (psql `\i` paths are relative to the working directory).

```bash
cd postgres/PostDeploymentScripts
psql -U postgres -d wideworldimporters -f script_post_deployment1.sql
```

## Script execution order

| File | Content |
|---|---|
| `pds100-ins-app-people.sql` | Application.People — staff, contacts |
| `pds105-ins-dls-ficticiousnamepool.sql` | DataLoadSimulation.FictitiousNamePool |
| `pds106-ins-dls-areacode.sql` | DataLoadSimulation.AreaCode |
| `pds110-ins-app-countries.sql` | Application.Countries (geography borders as NULL — see TODOs) |
| `pds120-ins-app-deliverymethods.sql` | Application.DeliveryMethods |
| `pds130-ins-app-paymentmethods.sql` | Application.PaymentMethods |
| `pds140-ins-app-stateprovinces.sql` | Application.StateProvinces (US states + territories) |
| `pds142-upd-app-stateprovinces-borders.sql` | Update state borders (PostGIS geometry) |
| `pds150-ins-app-cities.sql` | Application.Cities — core subset |
| `pds151-ins-post-app-cities.sql` | Dedup cleanup for cities |
| `pds160-ins-app-transactiontypes.sql` | Application.TransactionTypes |
| `pds170-ins-purchasing-suppliercategories.sql` | Purchasing.SupplierCategories |
| `pds180-ins-sales-groups-categories.sql` | Sales.BuyingGroups, Sales.CustomerCategories |
| `pds190-ins-warehouse-colors.sql` | Warehouse.Colors |
| `pds200-ins-warehouse-packagetypes.sql` | Warehouse.PackageTypes |
| `pds210-ins-warehouse-stockgroups.sql` | Warehouse.StockGroups |
| `pds220-ins-purchasing-suppliers.sql` | Purchasing.Suppliers (13 rows, uses GetRandomCity) |
| `pds230-ins-sales-customers.sql` | Sales.Customers (~663 rows, CURSOR→FOR loop) |
| `pds240-ins-warehouse-stockitems.sql` | Warehouse.StockItems (219 rows) |
| `pds250-ins-warehouse-stockitemholdings.sql` | Warehouse.StockItemHoldings |
| `pds260-ins-warehouse-stockitemstockgroups.sql` | Warehouse.StockItemStockGroups |
| `pds270-ins-app-systemparameters.sql` | Application.SystemParameters (1 row, uses GetRandomCity) |
| `pds400-ins-unkown-orderline.sql` | Sales.OrderLines — single row for tuning demo |
| `pds410-update-archive-tables.sql` | Update Warehouse.StockItems_Archive history prices |

## Optional full city load

The 26 `pds150-ins-app-cities-{a..z}.sql` files contain the complete city dataset (~38K additional rows). They are commented out in `script_post_deployment1.sql` by default. Uncomment to load all cities.

## Known TODOs

- **`pds110-ins-app-countries.sql`**: Country border geography is set to `NULL`. The MSSQL source stores polygon WKB in a proprietary format that requires a separate conversion tool. Reference data rows are still inserted; only the `Border` column is null.
- **`pds142-upd-app-stateprovinces-borders.sql`**: State border WKB is converted to PostGIS format. If you see geometry errors, verify PostGIS version compatibility.

## Skipped source files

`wwi-ssdt/wwi-ssdt/Storage/` (6 files) — filegroups, partition functions, and partition schemes have no PostgreSQL equivalent and are skipped entirely.
