# WideWorldImporters: Full MSSQL → PostgreSQL + FastAPI Migration Plan

## Context

The WideWorldImporters MSSQL sample database needs a complete conversion to PostgreSQL DDL and a FastAPI application layer. Zero files have been converted so far. The work spans ~336 source files and must be executed across multiple Claude Code sessions. All work uses **only the slash commands defined in `.claude/commands/`** — no ad-hoc rewrites.

## Scope

| Area | Decision |
|---|---|
| DataLoadSimulation | Convert all (tables + 10 functions + 42 SPs) |
| PostDeploymentScripts | Adapt 51 INSERT scripts to PostgreSQL syntax via `/mssql-to-postgres` |
| Application config SPs | Convert applicable (RLS), stub MSSQL-only ones (columnstore, in-memory OLTP, full-text, partitioning) |
| API generation | Not applicable — API layer is .NET; PostgreSQL functions are called directly via Npgsql |
| Security scripts | Defer — PostgreSQL GRANT/ROLE equivalents require separate treatment |
| Storage scripts | Skip — filegroups/partitions don't apply to PostgreSQL |

## Per-SP Workflow (for all Stored Procedures)

```
/mssql-to-pgfunc <sp-path>        → postgres/<Schema>/Functions/<name>.sql
/pgfunc-test <func-path>          → smoke test in wwi_test schema
```

Note: API layer is .NET — no FastAPI endpoint generation. The PL/pgSQL functions are called directly from .NET via Npgsql.

## File Naming Conventions

- Table output files: preserve source casing (`Orders.sql` → `postgres/Sales/Tables/Orders.sql`)
- View output files: lowercase (`customers.sql` → `postgres/WebApi/Views/customers.sql`)
- Function output files: lowercase snake_case (`delete_buying_group.sql`)
- Test prerequisite: `postgres_15.1` Docker container must be running

## Dependency Order Principle

Sequences → Application root tables → Cross-schema ref tables → Purchasing/Sales/Warehouse core → Transaction/line tables → DataLoadSimulation tables → UDTs → Views → Functions/SPs → API → Seed data

---

## Session-by-Session Execution Plan

### Session 1 — Sequences + Application Tables ✓ COMPLETED 2026-05-18

**Results:** 26 sequences + 16 Application tables converted and tested. All 16/16 pgtable-tests pass. PostGIS installed; 7 geography columns verified. PR #5: `feature/session1-migration`.

**Sequences (26 files — bulk):**
```
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Sequences/
```
Sequences are validated implicitly when the tables that reference them pass their pgtable-test.

**Application root tables (no external FKs):**
```
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/Countries.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/Countries_Archive.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/DeliveryMethods.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/DeliveryMethods_Archive.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/PaymentMethods.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/PaymentMethods_Archive.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/TransactionTypes.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/TransactionTypes_Archive.sql
```

**Application tables ordered by FK depth:**
```
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/StateProvinces.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/StateProvinces_Archive.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/Cities.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/Cities_Archive.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/People.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/People_Archive.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/SystemParameters.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/Logs.sql
```

**Tests — Session 1:**
```
/pgtable-test postgres/Application/Tables/Countries.sql
/pgtable-test postgres/Application/Tables/Countries_Archive.sql
/pgtable-test postgres/Application/Tables/DeliveryMethods.sql
/pgtable-test postgres/Application/Tables/DeliveryMethods_Archive.sql
/pgtable-test postgres/Application/Tables/PaymentMethods.sql
/pgtable-test postgres/Application/Tables/PaymentMethods_Archive.sql
/pgtable-test postgres/Application/Tables/TransactionTypes.sql
/pgtable-test postgres/Application/Tables/TransactionTypes_Archive.sql
/pgtable-test postgres/Application/Tables/StateProvinces.sql
/pgtable-test postgres/Application/Tables/StateProvinces_Archive.sql
/pgtable-test postgres/Application/Tables/Cities.sql
/pgtable-test postgres/Application/Tables/Cities_Archive.sql
/pgtable-test postgres/Application/Tables/People.sql
/pgtable-test postgres/Application/Tables/People_Archive.sql
/pgtable-test postgres/Application/Tables/SystemParameters.sql
/pgtable-test postgres/Application/Tables/Logs.sql
```

---

### Session 2 — Cross-Schema Reference Tables + Suppliers ✓ COMPLETED 2026-05-18

**Results:** 14 tables (BuyingGroups, CustomerCategories, SupplierCategories, Colors, PackageTypes, StockGroups + all _Archive variants + Suppliers, Suppliers_Archive) converted and tested. All 14/14 pgtable-tests pass. PostGIS verified on Suppliers geography column.

**Sales reference tables:**
```
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Sales/Tables/BuyingGroups.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Sales/Tables/BuyingGroups_Archive.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Sales/Tables/CustomerCategories.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Sales/Tables/CustomerCategories_Archive.sql
```

**Purchasing reference tables:**
```
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Purchasing/Tables/SupplierCategories.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Purchasing/Tables/SupplierCategories_Archive.sql
```

**Warehouse reference tables:**
```
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Warehouse/Tables/Colors.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Warehouse/Tables/Colors_Archive.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Warehouse/Tables/PackageTypes.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Warehouse/Tables/PackageTypes_Archive.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Warehouse/Tables/StockGroups.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Warehouse/Tables/StockGroups_Archive.sql
```

**Suppliers (depend on Application + SupplierCategories):**
```
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Purchasing/Tables/Suppliers.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Purchasing/Tables/Suppliers_Archive.sql
```

**Tests — Session 2:**
```
/pgtable-test postgres/Sales/Tables/BuyingGroups.sql
/pgtable-test postgres/Sales/Tables/BuyingGroups_Archive.sql
/pgtable-test postgres/Sales/Tables/CustomerCategories.sql
/pgtable-test postgres/Sales/Tables/CustomerCategories_Archive.sql
/pgtable-test postgres/Purchasing/Tables/SupplierCategories.sql
/pgtable-test postgres/Purchasing/Tables/SupplierCategories_Archive.sql
/pgtable-test postgres/Warehouse/Tables/Colors.sql
/pgtable-test postgres/Warehouse/Tables/Colors_Archive.sql
/pgtable-test postgres/Warehouse/Tables/PackageTypes.sql
/pgtable-test postgres/Warehouse/Tables/PackageTypes_Archive.sql
/pgtable-test postgres/Warehouse/Tables/StockGroups.sql
/pgtable-test postgres/Warehouse/Tables/StockGroups_Archive.sql
/pgtable-test postgres/Purchasing/Tables/Suppliers.sql
/pgtable-test postgres/Purchasing/Tables/Suppliers_Archive.sql
```

---

### Session 3 — Core Business Tables ✓ COMPLETED 2026-05-19

**Results:** 9 tables (StockItems, StockItems_Archive, StockItemHoldings, StockItemStockGroups, Customers, Customers_Archive, PurchaseOrders, PurchaseOrderLines, SpecialDeals) converted and tested. All 9/9 pgtable-tests pass. PostGIS verified on Customers.DeliveryLocation geography column.


**Customers + SpecialDeals (depend on Application + Sales ref):**
```
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Sales/Tables/Customers.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Sales/Tables/Customers_Archive.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Sales/Tables/SpecialDeals.sql
```

**Warehouse core (depend on Application + Purchasing.Suppliers + Warehouse ref):**
```
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Warehouse/Tables/StockItems.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Warehouse/Tables/StockItems_Archive.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Warehouse/Tables/StockItemHoldings.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Warehouse/Tables/StockItemStockGroups.sql
```

**Purchasing orders (depend on Application + Suppliers):**
```
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Purchasing/Tables/PurchaseOrders.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Purchasing/Tables/PurchaseOrderLines.sql
```

**Tests — Session 3:**
```
/pgtable-test postgres/Sales/Tables/Customers.sql
/pgtable-test postgres/Sales/Tables/Customers_Archive.sql
/pgtable-test postgres/Sales/Tables/SpecialDeals.sql
/pgtable-test postgres/Warehouse/Tables/StockItems.sql
/pgtable-test postgres/Warehouse/Tables/StockItems_Archive.sql
/pgtable-test postgres/Warehouse/Tables/StockItemHoldings.sql
/pgtable-test postgres/Warehouse/Tables/StockItemStockGroups.sql
/pgtable-test postgres/Purchasing/Tables/PurchaseOrders.sql
/pgtable-test postgres/Purchasing/Tables/PurchaseOrderLines.sql
```

---

### Session 4 — Transaction & Line-Item Tables + DataLoadSimulation + Misc ✓ COMPLETED 2026-05-19

**Results:** 15 tables converted and tested. All 15/15 pgtable-tests pass. Key special handling: MEMORY_OPTIMIZED stripped (3 tables), SYSTEM_VERSIONING stripped (ColdRoomTemperatures), COLUMNSTORE indexes omitted (OrderLines, InvoiceLines, StockItemTransactions), partition scheme PS_TransactionDate stripped (CustomerTransactions, SupplierTransactions), PERSISTED computed IsFinalized → BOOLEAN GENERATED ALWAYS AS STORED (CustomerTransactions, SupplierTransactions), non-persisted computed columns ConfirmedDeliveryTime/ConfirmedReceivedBy → plain nullable columns (Invoices).

### Session 4 — Transaction & Line-Item Tables + DataLoadSimulation + Misc

**Sales transactions:**
```
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Sales/Tables/Orders.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Sales/Tables/OrderLines.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Sales/Tables/Invoices.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Sales/Tables/InvoiceLines.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Sales/Tables/CustomerTransactions.sql
```

**Purchasing transactions:**
```
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Purchasing/Tables/SupplierTransactions.sql
```

**Warehouse transactions:**
```
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Warehouse/Tables/StockItemTransactions.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Warehouse/Tables/ColdRoomTemperatures.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Warehouse/Tables/ColdRoomTemperatures_Archive.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Warehouse/Tables/VehicleTemperatures.sql
```

**DataLoadSimulation tables:**
```
/mssql-to-postgres wwi-ssdt/wwi-ssdt/DataLoadSimulation/Tables/AreaCode.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/DataLoadSimulation/Tables/FicticiousNamePool.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/DataLoadSimulation/Tables/SeasonVariation.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/DataLoadSimulation/Tables/ColdRoomTemperatures_temp.sql
```

**Misc:**
```
/mssql-to-postgres wwi-ssdt/wwi-ssdt/dbo/Tables/SampleVersion.sql
```

**Tests — Session 4:**
```
/pgtable-test postgres/Sales/Tables/Orders.sql
/pgtable-test postgres/Sales/Tables/OrderLines.sql
/pgtable-test postgres/Sales/Tables/Invoices.sql
/pgtable-test postgres/Sales/Tables/InvoiceLines.sql
/pgtable-test postgres/Sales/Tables/CustomerTransactions.sql
/pgtable-test postgres/Purchasing/Tables/SupplierTransactions.sql
/pgtable-test postgres/Warehouse/Tables/StockItemTransactions.sql
/pgtable-test postgres/Warehouse/Tables/ColdRoomTemperatures.sql
/pgtable-test postgres/Warehouse/Tables/ColdRoomTemperatures_Archive.sql
/pgtable-test postgres/Warehouse/Tables/VehicleTemperatures.sql
/pgtable-test postgres/DataLoadSimulation/Tables/AreaCode.sql
/pgtable-test postgres/DataLoadSimulation/Tables/FicticiousNamePool.sql
/pgtable-test postgres/DataLoadSimulation/Tables/SeasonVariation.sql
/pgtable-test postgres/DataLoadSimulation/Tables/ColdRoomTemperatures_temp.sql
/pgtable-test postgres/dbo/Tables/SampleVersion.sql
```

---

### Session 5 — Website UDTs + All Functions ✓ COMPLETED 2026-05-19

**Results:** 4 UDTs converted (OrderIDList, OrderLineList, OrderList, SensorDataList). 12 functions converted and tested across Application (1), DataLoadSimulation (10), Website (1). All 12/12 pgfunc-tests pass. Key special handling: MEMORY_OPTIMIZED stripped from all UDTs, IDENTITY stripped from SensorDataList, IS_ROLEMEMBER → pg_has_role with EXCEPTION WHEN undefined_object wrapper (DetermineCustomerAccess), ABS(CHECKSUM(NEWID())) → random() (GetBogativePhoneNumber was a SP with OUTPUT param converted to scalar function), unquoted column names used throughout to match lowercase-folded DDL.

### Session 5 — Website UDTs + All Functions

**Website User Defined Types:**
```
/mssql-to-pgudt "wwi-ssdt/wwi-ssdt/Website/User Defined Types/OrderIDList.sql"
/mssql-to-pgudt "wwi-ssdt/wwi-ssdt/Website/User Defined Types/OrderLineList.sql"
/mssql-to-pgudt "wwi-ssdt/wwi-ssdt/Website/User Defined Types/OrderList.sql"
/mssql-to-pgudt "wwi-ssdt/wwi-ssdt/Website/User Defined Types/SensorDataList.sql"
```
UDTs produce composite types; verify output SQL file parses without error (no dedicated test skill — verify manually via `psql \d` on the type).

**Application function:**
```
/mssql-to-pgfunc wwi-ssdt/wwi-ssdt/Application/Functions/DetermineCustomerAccess.sql
```

**DataLoadSimulation functions (10):**
```
/mssql-to-pgfunc wwi-ssdt/wwi-ssdt/DataLoadSimulation/Functions/GetAreaCode.sql
/mssql-to-pgfunc wwi-ssdt/wwi-ssdt/DataLoadSimulation/Functions/GetBogativePhoneNumber.sql
/mssql-to-pgfunc wwi-ssdt/wwi-ssdt/DataLoadSimulation/Functions/GetCityLocation.sql
/mssql-to-pgfunc wwi-ssdt/wwi-ssdt/DataLoadSimulation/Functions/GetCustomerCount.sql
/mssql-to-pgfunc wwi-ssdt/wwi-ssdt/DataLoadSimulation/Functions/GetDeliveryMethodID.sql
/mssql-to-pgfunc wwi-ssdt/wwi-ssdt/DataLoadSimulation/Functions/GetPaymentMethodID.sql
/mssql-to-pgfunc wwi-ssdt/wwi-ssdt/DataLoadSimulation/Functions/GetPersonID.sql
/mssql-to-pgfunc wwi-ssdt/wwi-ssdt/DataLoadSimulation/Functions/GetStateProvinceID.sql
/mssql-to-pgfunc wwi-ssdt/wwi-ssdt/DataLoadSimulation/Functions/GetSupplierCategoryID.sql
/mssql-to-pgfunc wwi-ssdt/wwi-ssdt/DataLoadSimulation/Functions/GetTransactionTypeID.sql
```

**Website function:**
```
/mssql-to-pgfunc wwi-ssdt/wwi-ssdt/Website/Functions/CalculateCustomerPrice.sql
```

**Tests — Session 5:**
```
/pgfunc-test postgres/Application/Functions/determine_customer_access.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/get_area_code.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/get_bogative_phone_number.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/get_city_location.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/get_customer_count.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/get_delivery_method_id.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/get_payment_method_id.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/get_person_id.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/get_state_province_id.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/get_supplier_category_id.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/get_transaction_type_id.sql
/pgfunc-test postgres/Website/Functions/calculate_customer_price.sql
```

---

### Session 6 — Views ✓ COMPLETED 2026-05-19

**Results:** 26 views converted and smoke-tested. All 26/26 pgview-tests pass. Key special handling: PostGIS `ST_X`/`ST_Y` for geography `.Long`/`.Lat` accessors (Cities, Customers, Suppliers, SalesOrders views); `ST_AsGeoJSON(border::geometry)::json` for StateProvinces border (replacing complex REPLACE chain); `json_build_object` for GeoJSON DeliveryLocation in Customers/Suppliers/SalesOrders; `FOR JSON PATH, WITHOUT_ARRAY_WRAPPER` → `row_to_json` / `json_build_object` (flagged with TODOs); reversed column aliases (`Alias = expr` → `expr AS Alias`) in PurchaseOrders, SalesOrders, etc.; `DECOMPRESS()` → NULL with TODO comment in Website/VehicleTemperatures. All views pass 0-row smoke queries in the shared `postgres_15.1` container.

**WebApi views (bulk — 23 files):**
```
/mssql-to-pgview wwi-ssdt/wwi-ssdt/WebApi/Views
```

**Website views (3 files):**
```
/mssql-to-pgview wwi-ssdt/wwi-ssdt/Website/Views/Customers.sql
/mssql-to-pgview wwi-ssdt/wwi-ssdt/Website/Views/Suppliers.sql
/mssql-to-pgview wwi-ssdt/wwi-ssdt/Website/Views/VehicleTemperatures.sql
```

**Tests — Session 6:**
```
/pgview-test postgres/WebApi/Views/buying_groups.sql
/pgview-test postgres/WebApi/Views/cities.sql
/pgview-test postgres/WebApi/Views/colors.sql
/pgview-test postgres/WebApi/Views/countries.sql
/pgview-test postgres/WebApi/Views/customer_categories.sql
/pgview-test postgres/WebApi/Views/customers.sql
/pgview-test postgres/WebApi/Views/customer_transactions.sql
/pgview-test postgres/WebApi/Views/delivery_methods.sql
/pgview-test postgres/WebApi/Views/invoices.sql
/pgview-test postgres/WebApi/Views/package_types.sql
/pgview-test postgres/WebApi/Views/payment_methods.sql
/pgview-test postgres/WebApi/Views/purchase_order_lines.sql
/pgview-test postgres/WebApi/Views/purchase_orders.sql
/pgview-test postgres/WebApi/Views/sales_order_lines.sql
/pgview-test postgres/WebApi/Views/sales_orders.sql
/pgview-test postgres/WebApi/Views/special_deals.sql
/pgview-test postgres/WebApi/Views/state_provinces.sql
/pgview-test postgres/WebApi/Views/stock_groups.sql
/pgview-test postgres/WebApi/Views/stock_items.sql
/pgview-test postgres/WebApi/Views/supplier_categories.sql
/pgview-test postgres/WebApi/Views/suppliers.sql
/pgview-test postgres/WebApi/Views/supplier_transactions.sql
/pgview-test postgres/WebApi/Views/transaction_types.sql
/pgview-test postgres/Website/Views/customers.sql
/pgview-test postgres/Website/Views/suppliers.sql
/pgview-test postgres/Website/Views/vehicle_temperatures.sql
```

---

### Session 7 — WebApi Delete* + Login + SearchForStockItems SPs (17 SPs) ✓ COMPLETED 2026-05-19

**Results:** 17 functions converted; all 17/17 pgfunc-tests pass. Key special handling: Login SP had password check commented out in original — p_password accepted but not validated; SearchForStockItems uses `webapi.stock_items` view, CROSS APPLY OPENJSON → `CROSS JOIN LATERAL jsonb_array_elements_text`, FOR JSON PATH WITHOUT_ARRAY_WRAPPER → single-row SELECT returning `{value, tags}` jsonb (TODO: verify JSON shape). Note: FastAPI endpoints were initially generated then removed — API layer is .NET calling PostgreSQL functions directly.

Per-SP workflow: `/mssql-to-pgfunc` → `/pgfunc-test` → `/mssql-to-api`

SP source path prefix: `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/`

```
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteBuyingGroup.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteCity.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteColor.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteCountry.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteCustomerCategory.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteCustomer.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteDeliveryMethod.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeletePackageType.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeletePaymentMethod.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteStateProvince.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteStockGroup.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteStockItem.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteSupplierCategory.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteSupplier.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteTransactionType.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/Login.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/SearchForStockItems.sql"
```

**Tests — Session 7:**
```
/pgfunc-test postgres/WebApi/Functions/delete_buying_group.sql
/pgfunc-test postgres/WebApi/Functions/delete_city.sql
/pgfunc-test postgres/WebApi/Functions/delete_color.sql
/pgfunc-test postgres/WebApi/Functions/delete_country.sql
/pgfunc-test postgres/WebApi/Functions/delete_customer_category.sql
/pgfunc-test postgres/WebApi/Functions/delete_customer.sql
/pgfunc-test postgres/WebApi/Functions/delete_delivery_method.sql
/pgfunc-test postgres/WebApi/Functions/delete_package_type.sql
/pgfunc-test postgres/WebApi/Functions/delete_payment_method.sql
/pgfunc-test postgres/WebApi/Functions/delete_state_province.sql
/pgfunc-test postgres/WebApi/Functions/delete_stock_group.sql
/pgfunc-test postgres/WebApi/Functions/delete_stock_item.sql
/pgfunc-test postgres/WebApi/Functions/delete_supplier_category.sql
/pgfunc-test postgres/WebApi/Functions/delete_supplier.sql
/pgfunc-test postgres/WebApi/Functions/delete_transaction_type.sql
/pgfunc-test postgres/WebApi/Functions/login.sql
/pgfunc-test postgres/WebApi/Functions/search_for_stock_items.sql
```

Then for each function that passed: run `/mssql-to-api` against the original SP source path.

---

### Session 8 — WebApi Insert*FromJson SPs (15 SPs)

```
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertBuyingGroupsFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertCitiesFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertColorsFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertCountriesFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertCustomerCategoriesFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertCustomersFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertDeliveryMethodsFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertPackageTypesFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertPaymentMethodsFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertStateProvincesFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertStockGroupsFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertStockItemsFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertSupplierCategoriesFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertSuppliersFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertTransactionTypesFromJson.sql"
```

**Tests — Session 8:**
```
/pgfunc-test postgres/WebApi/Functions/insert_buying_groups_from_json.sql
/pgfunc-test postgres/WebApi/Functions/insert_cities_from_json.sql
/pgfunc-test postgres/WebApi/Functions/insert_colors_from_json.sql
/pgfunc-test postgres/WebApi/Functions/insert_countries_from_json.sql
/pgfunc-test postgres/WebApi/Functions/insert_customer_categories_from_json.sql
/pgfunc-test postgres/WebApi/Functions/insert_customers_from_json.sql
/pgfunc-test postgres/WebApi/Functions/insert_delivery_methods_from_json.sql
/pgfunc-test postgres/WebApi/Functions/insert_package_types_from_json.sql
/pgfunc-test postgres/WebApi/Functions/insert_payment_methods_from_json.sql
/pgfunc-test postgres/WebApi/Functions/insert_state_provinces_from_json.sql
/pgfunc-test postgres/WebApi/Functions/insert_stock_groups_from_json.sql
/pgfunc-test postgres/WebApi/Functions/insert_stock_items_from_json.sql
/pgfunc-test postgres/WebApi/Functions/insert_supplier_categories_from_json.sql
/pgfunc-test postgres/WebApi/Functions/insert_suppliers_from_json.sql
/pgfunc-test postgres/WebApi/Functions/insert_transaction_types_from_json.sql
```

---

### Session 9 — WebApi Update*FromJson SPs batch 1 (14 SPs)

```
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateBuyingGroupFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateCityFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateColorFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateCountryFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateCustomerCategoryFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateCustomerFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateCustomerTransactionFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateDeliveryMethodFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateInvoiceFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdatePackageTypeFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdatePaymentMethodFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdatePurchaseOrderFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateSalesOrderFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateSpecialDealFromJson.sql"
```

**Tests — Session 9:**
```
/pgfunc-test postgres/WebApi/Functions/update_buying_group_from_json.sql
/pgfunc-test postgres/WebApi/Functions/update_city_from_json.sql
/pgfunc-test postgres/WebApi/Functions/update_color_from_json.sql
/pgfunc-test postgres/WebApi/Functions/update_country_from_json.sql
/pgfunc-test postgres/WebApi/Functions/update_customer_category_from_json.sql
/pgfunc-test postgres/WebApi/Functions/update_customer_from_json.sql
/pgfunc-test postgres/WebApi/Functions/update_customer_transaction_from_json.sql
/pgfunc-test postgres/WebApi/Functions/update_delivery_method_from_json.sql
/pgfunc-test postgres/WebApi/Functions/update_invoice_from_json.sql
/pgfunc-test postgres/WebApi/Functions/update_package_type_from_json.sql
/pgfunc-test postgres/WebApi/Functions/update_payment_method_from_json.sql
/pgfunc-test postgres/WebApi/Functions/update_purchase_order_from_json.sql
/pgfunc-test postgres/WebApi/Functions/update_sales_order_from_json.sql
/pgfunc-test postgres/WebApi/Functions/update_special_deal_from_json.sql
```

---

### Session 10 — WebApi Update*FromJson SPs batch 2 (7 SPs)

```
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateStateProvinceFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateStockGroupFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateStockItemFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateSupplierCategoryFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateSupplierFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateSupplierTransactionFromJson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateTransactionTypeFromJson.sql"
```

**Tests — Session 10:**
```
/pgfunc-test postgres/WebApi/Functions/update_state_province_from_json.sql
/pgfunc-test postgres/WebApi/Functions/update_stock_group_from_json.sql
/pgfunc-test postgres/WebApi/Functions/update_stock_item_from_json.sql
/pgfunc-test postgres/WebApi/Functions/update_supplier_category_from_json.sql
/pgfunc-test postgres/WebApi/Functions/update_supplier_from_json.sql
/pgfunc-test postgres/WebApi/Functions/update_supplier_transaction_from_json.sql
/pgfunc-test postgres/WebApi/Functions/update_transaction_type_from_json.sql
```

---

### Session 11 — Website SPs (11 SPs)

SP source path prefix: `wwi-ssdt/wwi-ssdt/Website/Stored Procedures/`

```
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Website/Stored Procedures/ActivateWebsiteLogon.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Website/Stored Procedures/ChangePassword.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Website/Stored Procedures/InsertCustomerOrders.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Website/Stored Procedures/InvoiceCustomerOrders.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Website/Stored Procedures/RecordColdRoomTemperatures.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Website/Stored Procedures/RecordVehicleTemperature.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Website/Stored Procedures/SearchForCustomers.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Website/Stored Procedures/SearchForPeople.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Website/Stored Procedures/SearchForStockItems.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Website/Stored Procedures/SearchForStockItemsByTags.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Website/Stored Procedures/SearchForSuppliers.sql"
```

**Tests — Session 11:**
```
/pgfunc-test postgres/Website/Functions/activate_website_logon.sql
/pgfunc-test postgres/Website/Functions/change_password.sql
/pgfunc-test postgres/Website/Functions/insert_customer_orders.sql
/pgfunc-test postgres/Website/Functions/invoice_customer_orders.sql
/pgfunc-test postgres/Website/Functions/record_cold_room_temperatures.sql
/pgfunc-test postgres/Website/Functions/record_vehicle_temperature.sql
/pgfunc-test postgres/Website/Functions/search_for_customers.sql
/pgfunc-test postgres/Website/Functions/search_for_people.sql
/pgfunc-test postgres/Website/Functions/search_for_stock_items.sql
/pgfunc-test postgres/Website/Functions/search_for_stock_items_by_tags.sql
/pgfunc-test postgres/Website/Functions/search_for_suppliers.sql
```

---

### Session 12 — Integration SPs (13 SPs)

SP source path prefix: `wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/`

```
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetCityUpdates.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetCustomerUpdates.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetEmployeeUpdates.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetMovementUpdates.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetOrderUpdates.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetPaymentMethodUpdates.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetPurchaseUpdates.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetSaleUpdates.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetStockHoldingUpdates.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetStockItemUpdates.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetSupplierUpdates.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetTransactionTypeUpdates.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetTransactionUpdates.sql"
```

**Tests — Session 12:**
```
/pgfunc-test postgres/Integration/Functions/get_city_updates.sql
/pgfunc-test postgres/Integration/Functions/get_customer_updates.sql
/pgfunc-test postgres/Integration/Functions/get_employee_updates.sql
/pgfunc-test postgres/Integration/Functions/get_movement_updates.sql
/pgfunc-test postgres/Integration/Functions/get_order_updates.sql
/pgfunc-test postgres/Integration/Functions/get_payment_method_updates.sql
/pgfunc-test postgres/Integration/Functions/get_purchase_updates.sql
/pgfunc-test postgres/Integration/Functions/get_sale_updates.sql
/pgfunc-test postgres/Integration/Functions/get_stock_holding_updates.sql
/pgfunc-test postgres/Integration/Functions/get_stock_item_updates.sql
/pgfunc-test postgres/Integration/Functions/get_supplier_updates.sql
/pgfunc-test postgres/Integration/Functions/get_transaction_type_updates.sql
/pgfunc-test postgres/Integration/Functions/get_transaction_updates.sql
```

---

### Session 13 — Application SPs (16 SPs)

**Utility SPs:**
```
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Application/Stored Procedures/AddRoleMemberIfNonexistent.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Application/Stored Procedures/CreateRoleIfNonexistent.sql"
```

**Configuration SPs — applicable (convert to PostgreSQL equivalents):**
```
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_ApplyRowLevelSecurity.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_RemoveRowLevelSecurity.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_ApplyAuditing.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_RemoveAuditing.sql"
```

**Configuration SPs — MSSQL-only (convert to stub no-op functions with RAISE NOTICE):**
```
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_ApplyColumnstoreIndexing.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_RemoveColumnstoreIndexing.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_ApplyFullTextIndexing.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_ApplyPartitioning.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_EnableInMemory.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_DisableInMemory.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_ConfigureForEnterpriseEdition.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_PrepareForAzureStandard.sql"
```

**Sequences SPs:**
```
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Sequences/Stored Procedures/ReseedAllSequences.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Sequences/Stored Procedures/ReseedSequenceBeyondTableValues.sql"
```

**Tests — Session 13:**
```
/pgfunc-test postgres/Application/Functions/add_role_member_if_nonexistent.sql
/pgfunc-test postgres/Application/Functions/create_role_if_nonexistent.sql
/pgfunc-test postgres/Application/Functions/configuration_apply_row_level_security.sql
/pgfunc-test postgres/Application/Functions/configuration_remove_row_level_security.sql
/pgfunc-test postgres/Application/Functions/configuration_apply_auditing.sql
/pgfunc-test postgres/Application/Functions/configuration_remove_auditing.sql
/pgfunc-test postgres/Application/Functions/configuration_apply_columnstore_indexing.sql
/pgfunc-test postgres/Application/Functions/configuration_remove_columnstore_indexing.sql
/pgfunc-test postgres/Application/Functions/configuration_apply_full_text_indexing.sql
/pgfunc-test postgres/Application/Functions/configuration_apply_partitioning.sql
/pgfunc-test postgres/Application/Functions/configuration_enable_in_memory.sql
/pgfunc-test postgres/Application/Functions/configuration_disable_in_memory.sql
/pgfunc-test postgres/Application/Functions/configuration_configure_for_enterprise_edition.sql
/pgfunc-test postgres/Application/Functions/configuration_prepare_for_azure_standard.sql
/pgfunc-test postgres/Sequences/Functions/reseed_all_sequences.sql
/pgfunc-test postgres/Sequences/Functions/reseed_sequence_beyond_table_values.sql
```

---

### Session 14 — DataLoadSimulation SPs batch 1 (22 SPs)

SP source path prefix: `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/`

```
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/ActivateWebsiteLogons.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/AddCustomers.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/AddSpecialDeals.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/AddStockItems.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/ChangePasswords.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/CreateCustomerOrders.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/DailyProcessToCreateHistory.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/DeactivateTemporalTablesBeforeDataLoad.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetBogativePostalCode.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetBuyingGroupDomain.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetFicticiousName.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomBuyingGroup.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomBuyingGroupNotInUse.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomCity.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomCustomer.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomCustomerCategory.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomDeliveryMethod.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomEmployeePerson.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomPaymentDays.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomSalesPersonID.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomSecondaryAddress.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomStockItemToAdjust.sql"
```

**Tests — Session 14:**
```
/pgfunc-test postgres/DataLoadSimulation/Functions/activate_website_logons.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/add_customers.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/add_special_deals.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/add_stock_items.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/change_passwords.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/create_customer_orders.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/daily_process_to_create_history.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/deactivate_temporal_tables_before_data_load.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/get_bogative_postal_code.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/get_buying_group_domain.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/get_ficticious_name.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/get_random_buying_group.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/get_random_buying_group_not_in_use.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/get_random_city.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/get_random_customer.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/get_random_customer_category.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/get_random_delivery_method.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/get_random_employee_person.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/get_random_payment_days.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/get_random_sales_person_id.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/get_random_secondary_address.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/get_random_stock_item_to_adjust.sql
```

---

### Session 15 — DataLoadSimulation SPs batch 2 (20 SPs)

```
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomStreet.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomStreetName.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomStreetSuffix.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/InvoicePickedOrders.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/MakeTemporalChanges.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/PaySuppliers.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/PerformStocktake.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/PickStockForCustomerOrders.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/PlaceSupplierOrders.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/PopulateColdRoomTemperatures_temp.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/PopulateDataTo180DaysAgo.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/PopulateDataToCurrentDate.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/PopulateOneDayOfHistory.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/ProcessCustomerPayments.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/ReactivateTemporalTablesAfterDataLoad.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/ReceivePurchaseOrders.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/RecordColdRoomTemperatures.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/RecordDeliveryVanTemperatures.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/RecordInvoiceDeliveries.sql"
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/UpdateCustomFields.sql"
```

**Tests — Session 15:**
```
/pgfunc-test postgres/DataLoadSimulation/Functions/get_random_street.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/get_random_street_name.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/get_random_street_suffix.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/invoice_picked_orders.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/make_temporal_changes.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/pay_suppliers.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/perform_stocktake.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/pick_stock_for_customer_orders.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/place_supplier_orders.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/populate_cold_room_temperatures_temp.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/populate_data_to_180_days_ago.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/populate_data_to_current_date.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/populate_one_day_of_history.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/process_customer_payments.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/reactivate_temporal_tables_after_data_load.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/receive_purchase_orders.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/record_cold_room_temperatures.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/record_delivery_van_temperatures.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/record_invoice_deliveries.sql
/pgfunc-test postgres/DataLoadSimulation/Functions/update_custom_fields.sql
```

---

### Session 16 — PostDeploymentScripts batch 1 (~26 files)

Use `/mssql-to-postgres` on each INSERT script. Review output for residual T-SQL syntax (`[brackets]`, `GO`, `GETDATE()` → `NOW()`, `NEWID()` → `gen_random_uuid()`, `CAST(... AS NVARCHAR)` → `CAST(... AS TEXT)`).

Output path: `postgres/PostDeploymentScripts/`

There is no automated smoke test skill for INSERT scripts. Verify by checking that the output file has no `[` brackets, no `GO` statements, and correct PostgreSQL data type casts.

```
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds100-ins-app-people.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds105-ins-dls-ficticiousnamepool.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds106-ins-dls-areacode.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds110-ins-app-countries.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds120-ins-app-deliverymethods.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds130-ins-app-paymentmethods.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds140-ins-app-stateprovinces.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds142-upd-app-stateprovinces-borders.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds150-ins-app-cities.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds150-ins-app-cities-a.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds150-ins-app-cities-b.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds150-ins-app-cities-c.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds150-ins-app-cities-d.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds150-ins-app-cities-e.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds150-ins-app-cities-f.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds150-ins-app-cities-g.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds150-ins-app-cities-h.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds150-ins-app-cities-i.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds150-ins-app-cities-j.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds150-ins-app-cities-k.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds150-ins-app-cities-l.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds150-ins-app-cities-m.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds150-ins-app-cities-n.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds150-ins-app-cities-o.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds150-ins-app-cities-p.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds150-ins-app-cities-q.sql
```

---

### Session 17 — PostDeploymentScripts batch 2 (~25 files)

```
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds150-ins-app-cities-r.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds150-ins-app-cities-s.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds150-ins-app-cities-t.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds150-ins-app-cities-u.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds150-ins-app-cities-v.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds150-ins-app-cities-w.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds150-ins-app-cities-x.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds150-ins-app-cities-y.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds150-ins-app-cities-z.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds151-ins-post-app-cities.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds160-ins-app-transactiontypes.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds170-ins-purchasing-suppliercategories.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds180-ins-sales-groups-categories.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds190-ins-warehouse-colors.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds200-ins-warehouse-packagetypes.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds210-ins-warehouse-stockgroups.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds220-ins-purchasing-suppliers.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds230-ins-sales-customers.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds240-ins-warehouse-stockitems.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds250-ins-warehouse-stockitemholdings.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds260-ins-warehouse-stockitemstockgroups.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds270-ins-app-systemparameters.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds400-ins-unkown-orderline.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds410-update-archive-tables.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/PostDeploymentScripts/Script.PostDeployment1.sql
```

---

### Session 18 — Final Validation & Gap Report

1. Run `/mssql-list-deps` on any SP flagged during earlier sessions as having unresolved dependencies.
2. Re-run any `*-test` that failed in previous sessions after fixes are applied.
3. Count converted files: `find postgres/ -name "*.sql" | wc -l` should be ≥ 257 (tables + views + functions; UDTs and PostDeploymentScripts are supplemental).
4. List any source files without a corresponding `postgres/` output file and queue them for a follow-up session.

---

## File Counts by Session

| Session | Objects | Skills Used |
|---|---|---|
| 1 | 26 sequences + 16 Application tables | mssql-to-postgres, pgtable-test |
| 2 | 14 ref tables + 2 Suppliers | mssql-to-postgres, pgtable-test |
| 3 | 11 core business tables | mssql-to-postgres, pgtable-test |
| 4 | 17 transaction/line tables + 5 misc | mssql-to-postgres, pgtable-test |
| 5 | 4 UDTs + 12 functions | mssql-to-pgudt, mssql-to-pgfunc, pgfunc-test |
| 6 | 26 views | mssql-to-pgview, pgview-test |
| 7 | 17 WebApi SPs | mssql-to-pgfunc, pgfunc-test |
| 8 | 15 WebApi Insert SPs | mssql-to-pgfunc, pgfunc-test |
| 9 | 14 WebApi Update SPs | mssql-to-pgfunc, pgfunc-test |
| 10 | 7 WebApi Update SPs | mssql-to-pgfunc, pgfunc-test |
| 11 | 11 Website SPs | mssql-to-pgfunc, pgfunc-test |
| 12 | 13 Integration SPs | mssql-to-pgfunc, pgfunc-test |
| 13 | 16 Application + Sequences SPs | mssql-to-pgfunc, pgfunc-test |
| 14 | 22 DataLoadSim SPs | mssql-to-pgfunc, pgfunc-test |
| 15 | 20 DataLoadSim SPs | mssql-to-pgfunc, pgfunc-test |
| 16 | 26 PostDeployment scripts | mssql-to-postgres |
| 17 | 25 PostDeployment scripts | mssql-to-postgres |
| 18 | Validation sweep | mssql-list-deps, all *-test skills |

**Total: ~336 source objects across 18 sessions**

---

## Deferred / Out of Scope

- **Security scripts** (22 files in `Security/`): PostgreSQL uses `CREATE ROLE`, `GRANT`, `ALTER DEFAULT PRIVILEGES`. Handle separately after all schema objects are converted.
- **Storage scripts** (6 files in `Storage/`): Filegroups, partition functions/schemes don't apply to PostgreSQL. Skip.
- **_Archive temporal tables**: Converted as plain tables (PERIOD FOR SYSTEM_TIME stripped). Temporal audit history strategy (triggers, pg_audit, etc.) is a separate workstream.

---

## Critical Rules (from CLAUDE.md)

- **Never auto-commit** converted files. Leave all output uncommitted for manual review.
- Run `/mssql-list-deps` before converting any SP that references tables not yet confirmed converted.
- The `postgres_15.1` Docker container must be running for all `*-test` skills.
- Output schema/table names are **lowercase**; column names **preserve original casing**.
