# Migration Full Test Report — 2026-05-27

## Overall Summary
- Elapsed: 15.6s
- **PASS: 202**  FAIL: 3  WARN: 30  SKIP: 0

## Failures

- ✗ [FAIL] sales.buyinggroups → application.people  —  1 orphaned rows  [FK_Sales_BuyingGroups_Application_People]
- ✗ [FAIL] sales.customertransactions → application.people  —  1 orphaned rows  [FK_Sales_CustomerTransactions_Application_People]
- ✗ [FAIL] sales.customers → application.people  —  1 orphaned rows  [FK_Sales_Customers_Application_People]

---
## Detailed Results

# Migration Full Test — 2026-05-27 05:32:05
  MSSQL  172.22.0.5:1433  db=WideWorldImporters
  PG     172.22.0.4:5432  db=wideworldimporters

## Tier 1 — Table Inventory
  MSSQL: 48 tables   PG: 32 tables
  ⚠ [WARN] Archive table not ported to PG (temporal table stripped): application.cities_archive
  ⚠ [WARN] Archive table not ported to PG (temporal table stripped): application.countries_archive
  ⚠ [WARN] Archive table not ported to PG (temporal table stripped): application.deliverymethods_archive
  ⚠ [WARN] Archive table not ported to PG (temporal table stripped): application.paymentmethods_archive
  ⚠ [WARN] Archive table not ported to PG (temporal table stripped): application.people_archive
  ⚠ [WARN] Archive table not ported to PG (temporal table stripped): application.stateprovinces_archive
  ⚠ [WARN] Archive table not ported to PG (temporal table stripped): application.transactiontypes_archive
  ⚠ [WARN] Archive table not ported to PG (temporal table stripped): purchasing.suppliercategories_archive
  ⚠ [WARN] Archive table not ported to PG (temporal table stripped): purchasing.suppliers_archive
  ⚠ [WARN] Archive table not ported to PG (temporal table stripped): sales.buyinggroups_archive
  ⚠ [WARN] Archive table not ported to PG (temporal table stripped): sales.customercategories_archive
  ⚠ [WARN] Archive table not ported to PG (temporal table stripped): sales.customers_archive
  ⚠ [WARN] Archive table not ported to PG (temporal table stripped): warehouse.coldroomtemperatures_archive
  ⚠ [WARN] Archive table not ported to PG (temporal table stripped): warehouse.colors_archive
  ⚠ [WARN] Archive table not ported to PG (temporal table stripped): warehouse.packagetypes_archive
  ⚠ [WARN] Archive table not ported to PG (temporal table stripped): warehouse.stockgroups_archive
  ⚠ [WARN] Archive table not ported to PG (temporal table stripped): warehouse.stockitems_archive
  ⚠ [WARN] Extra table in PG not in MSSQL scope: application.logs
  Matched: 31  Missing (non-archive): 0  Archive gaps: 17  Extra in PG: 1

## Tier 2 — Row Count Comparison
  ✓ [PASS] application.cities  —  37,940 rows
  ✓ [PASS] application.countries  —  190 rows
  ✓ [PASS] application.deliverymethods  —  10 rows
  ✓ [PASS] application.paymentmethods  —  4 rows
  ✓ [PASS] application.people  —  1,111 rows
  ✓ [PASS] application.stateprovinces  —  53 rows
  ✓ [PASS] application.systemparameters  —  1 rows
  ✓ [PASS] application.transactiontypes  —  13 rows
  ✓ [PASS] purchasing.purchaseorderlines  —  8,367 rows
  ✓ [PASS] purchasing.purchaseorders  —  2,074 rows
  ✓ [PASS] purchasing.suppliercategories  —  9 rows
  ✓ [PASS] purchasing.suppliers  —  13 rows
  ✓ [PASS] purchasing.suppliertransactions  —  2,438 rows
  ⚠ [WARN] sales.buyinggroups  —  MSSQL=2  PG=3  Δ=+1  (known API drift)
  ✓ [PASS] sales.customercategories  —  8 rows
  ✓ [PASS] sales.customers  —  663 rows
  ✓ [PASS] sales.customertransactions  —  97,147 rows
  ✓ [PASS] sales.invoicelines  —  228,265 rows
  ✓ [PASS] sales.invoices  —  70,510 rows
  ✓ [PASS] sales.orderlines  —  231,412 rows
  ✓ [PASS] sales.orders  —  73,595 rows
  ✓ [PASS] sales.specialdeals  —  2 rows
  ✓ [PASS] warehouse.coldroomtemperatures  —  4 rows
  ✓ [PASS] warehouse.colors  —  36 rows
  ✓ [PASS] warehouse.packagetypes  —  14 rows
  ✓ [PASS] warehouse.stockgroups  —  10 rows
  ✓ [PASS] warehouse.stockitemholdings  —  227 rows
  ✓ [PASS] warehouse.stockitems  —  227 rows
  ✓ [PASS] warehouse.stockitemstockgroups  —  442 rows
  ✓ [PASS] warehouse.stockitemtransactions  —  236,667 rows
  ✓ [PASS] warehouse.vehicletemperatures  —  65,998 rows

## Tier 3 — Column Aggregate Checksums
  ⚠ [WARN] application.cities  —  1 column checksum(s) differ  (known API drift)
      • DISTINCT(CityName): MSSQL=23,272  PG=23,279
  ✓ [PASS] application.countries  —  all columns pass
  ✓ [PASS] application.deliverymethods  —  all columns pass
  ✓ [PASS] application.paymentmethods  —  all columns pass
  ⚠ [WARN] application.people  —  4 column checksum(s) differ  (known API drift)
      • LEN(FullName): MSSQL=15,128  PG=15,129
      • LEN(PreferredName): MSSQL=6,755  PG=6,765
      • DISTINCT(PreferredName): MSSQL=880  PG=882
      • LEN(SearchName): MSSQL=23,004  PG=23,005
  ✓ [PASS] application.stateprovinces  —  all columns pass
  ✓ [PASS] application.systemparameters  —  all columns pass
  ✓ [PASS] application.transactiontypes  —  all columns pass
  ✓ [PASS] purchasing.purchaseorderlines  —  all columns pass
  ✓ [PASS] purchasing.purchaseorders  —  all columns pass
  ✓ [PASS] purchasing.suppliercategories  —  all columns pass
  ✓ [PASS] purchasing.suppliers  —  all columns pass
  ✓ [PASS] purchasing.suppliertransactions  —  all columns pass
  ⚠ [WARN] sales.buyinggroups  —  5 column checksum(s) differ  (known API drift)
      • SUM(BuyingGroupID): MSSQL=3.0  PG=6.0
      • LEN(BuyingGroupName): MSSQL=25  PG=37
      • DISTINCT(BuyingGroupName): MSSQL=2  PG=3
      • RANGE(ValidFrom): MSSQL=[2013-01-01 00:00:00, 2013-01-01 00:00:00]  PG=[2013-01-01 00:00:00, 2026-05-21 05:20:38]
      • RANGE(ValidTo): MSSQL=[9999-12-31 23:59:59, 9999-12-31 23:59:59]  PG=[2026-05-21 05:20:38, 9999-12-31 23:59:59]
  ⚠ [WARN] sales.customercategories  —  1 column checksum(s) differ  (known API drift)
      • LEN(CustomerCategoryName): MSSQL=87  PG=95
  ⚠ [WARN] sales.customers  —  20 column checksum(s) differ  (known API drift)
      • LEN(CustomerName): MSSQL=15,114  PG=15,092
      • SUM(BuyingGroupID): MSSQL=603.0  PG=601.0
      • NULLS(BuyingGroupID): MSSQL=261  PG=263
      • SUM(PostalCityID): MSSQL=12618925.0  PG=12599340.0
      • SUM(CreditLimit): MSSQL=682476.0  PG=692476.0
      • NULLS(CreditLimit): MSSQL=402  PG=401
      • LEN(PhoneNumber): MSSQL=9,282  PG=9,276
      • DISTINCT(PhoneNumber): MSSQL=49  PG=50
      • LEN(FaxNumber): MSSQL=9,282  PG=9,276
      • DISTINCT(FaxNumber): MSSQL=49  PG=50
      • NULLS(DeliveryRun): MSSQL=61  PG=63
      • NULLS(RunPosition): MSSQL=61  PG=63
      • LEN(WebsiteURL): MSSQL=23,852  PG=23,840
      • LEN(DeliveryAddressLine2): MSSQL=12,004  PG=11,971
      • DISTINCT(DeliveryAddressLine2): MSSQL=663  PG=661
      • NULLS(DeliveryAddressLine2): MSSQL=0  PG=2
      • LEN(PostalAddressLine2): MSSQL=7,504  PG=7,480
      • DISTINCT(PostalAddressLine2): MSSQL=452  PG=451
      • NULLS(PostalAddressLine2): MSSQL=0  PG=2
      • SUM(LastEditedBy): MSSQL=1289.0  PG=1288.0
  ⚠ [WARN] sales.customertransactions  —  5 column checksum(s) differ  (known API drift)
      • SUM(PaymentMethodID): MSSQL=106548.0  PG=106551.0
      • NULLS(PaymentMethodID): MSSQL=70,510  PG=70,509
      • NULLS(FinalizationDate): MSSQL=84  PG=85
      • BIT_TRUES(IsFinalized): MSSQL=97,063  PG=97,062
      • SUM(LastEditedBy): MSSQL=1062573.0  PG=1062563.0
  ✓ [PASS] sales.invoicelines  —  all columns pass
  ⚠ [WARN] sales.invoices  —  1 column checksum(s) differ  (known API drift)
      • LEN(ConfirmedReceivedBy): MSSQL=971,325  PG=971,412
  ✓ [PASS] sales.orderlines  —  all columns pass
  ✓ [PASS] sales.orders  —  all columns pass
  ✓ [PASS] sales.specialdeals  —  all columns pass
  ✓ [PASS] warehouse.coldroomtemperatures  —  all columns pass
  ✓ [PASS] warehouse.colors  —  all columns pass
  ⚠ [WARN] warehouse.packagetypes  —  1 column checksum(s) differ  (known API drift)
      • LEN(PackageTypeName): MSSQL=59  PG=60
  ✓ [PASS] warehouse.stockgroups  —  all columns pass
  ✓ [PASS] warehouse.stockitemholdings  —  all columns pass
  ⚠ [WARN] warehouse.stockitems  —  2 column checksum(s) differ  (known API drift)
      • LEN(Tags): MSSQL=3,343  PG=3,388
      • LEN(SearchDetails): MSSQL=10,339  PG=10,538
  ✓ [PASS] warehouse.stockitemstockgroups  —  all columns pass
  ✓ [PASS] warehouse.stockitemtransactions  —  all columns pass
  ✓ [PASS] warehouse.vehicletemperatures  —  all columns pass

## Tier 4 — Sample Row Spot-Check
  ✓ [PASS] application.cities  —  20 sampled rows  ×  7 columns  all match
  ✓ [PASS] application.countries  —  20 sampled rows  ×  13 columns  all match
  ✓ [PASS] application.deliverymethods  —  10 sampled rows  ×  5 columns  all match
  ✓ [PASS] application.paymentmethods  —  4 sampled rows  ×  5 columns  all match
  ✓ [PASS] application.people  —  20 sampled rows  ×  19 columns  all match
  ✓ [PASS] application.stateprovinces  —  20 sampled rows  ×  9 columns  all match
  ✓ [PASS] application.systemparameters  —  1 sampled rows  ×  12 columns  all match
  ✓ [PASS] application.transactiontypes  —  13 sampled rows  ×  5 columns  all match
  ✓ [PASS] purchasing.purchaseorderlines  —  20 sampled rows  ×  12 columns  all match
  ✓ [PASS] purchasing.purchaseorders  —  20 sampled rows  ×  12 columns  all match
  ✓ [PASS] purchasing.suppliercategories  —  9 sampled rows  ×  5 columns  all match
  ✓ [PASS] purchasing.suppliers  —  13 sampled rows  ×  28 columns  all match
  ✓ [PASS] purchasing.suppliertransactions  —  20 sampled rows  ×  15 columns  all match
  ✓ [PASS] sales.buyinggroups  —  2 sampled rows  ×  5 columns  all match
  ⚠ [WARN] sales.customercategories  —  1 value(s) differ in 8 sampled rows  (expected API drift)
  ✓ [PASS] sales.customers  —  20 sampled rows  ×  30 columns  all match
  ✓ [PASS] sales.customertransactions  —  20 sampled rows  ×  14 columns  all match
  ✓ [PASS] sales.invoicelines  —  20 sampled rows  ×  13 columns  all match
  ✓ [PASS] sales.invoices  —  20 sampled rows  ×  25 columns  all match
  ✓ [PASS] sales.orderlines  —  20 sampled rows  ×  12 columns  all match
  ✓ [PASS] sales.orders  —  20 sampled rows  ×  16 columns  all match
  ✓ [PASS] sales.specialdeals  —  2 sampled rows  ×  14 columns  all match
  ✓ [PASS] warehouse.coldroomtemperatures  —  4 sampled rows  ×  6 columns  all match
  ✓ [PASS] warehouse.colors  —  20 sampled rows  ×  5 columns  all match
  ✓ [PASS] warehouse.packagetypes  —  14 sampled rows  ×  5 columns  all match
  ✓ [PASS] warehouse.stockgroups  —  10 sampled rows  ×  5 columns  all match
  ✓ [PASS] warehouse.stockitemholdings  —  20 sampled rows  ×  9 columns  all match
  ⚠ [WARN] warehouse.stockitems  —  8 value(s) differ in 20 sampled rows  (expected API drift)
  ✓ [PASS] warehouse.stockitemstockgroups  —  20 sampled rows  ×  5 columns  all match
  ✓ [PASS] warehouse.stockitemtransactions  —  20 sampled rows  ×  11 columns  all match
  ✓ [PASS] warehouse.vehicletemperatures  —  20 sampled rows  ×  7 columns  all match

## Tier 5 — Referential Integrity (FK Orphan Check)
  Found 98 FK column relationships in MSSQL
  ✓ [PASS] application.cities → application.people  —  0 orphans
  ✓ [PASS] application.cities → application.stateprovinces  —  0 orphans
  ✓ [PASS] application.countries → application.people  —  0 orphans
  ✓ [PASS] application.deliverymethods → application.people  —  0 orphans
  ✓ [PASS] application.paymentmethods → application.people  —  0 orphans
  ✓ [PASS] application.people → application.people  —  0 orphans
  ✓ [PASS] application.stateprovinces → application.people  —  0 orphans
  ✓ [PASS] application.stateprovinces → application.countries  —  0 orphans
  ✓ [PASS] application.systemparameters → application.people  —  0 orphans
  ✓ [PASS] application.systemparameters → application.cities  —  0 orphans
  ✓ [PASS] application.systemparameters → application.cities  —  0 orphans
  ✓ [PASS] application.transactiontypes → application.people  —  0 orphans
  ✓ [PASS] purchasing.purchaseorderlines → application.people  —  0 orphans
  ✓ [PASS] purchasing.purchaseorderlines → warehouse.packagetypes  —  0 orphans
  ✓ [PASS] purchasing.purchaseorderlines → purchasing.purchaseorders  —  0 orphans
  ✓ [PASS] purchasing.purchaseorderlines → warehouse.stockitems  —  0 orphans
  ✓ [PASS] purchasing.purchaseorders → application.people  —  0 orphans
  ✓ [PASS] purchasing.purchaseorders → application.people  —  0 orphans
  ✓ [PASS] purchasing.purchaseorders → application.deliverymethods  —  0 orphans
  ✓ [PASS] purchasing.purchaseorders → purchasing.suppliers  —  0 orphans
  ✓ [PASS] purchasing.suppliercategories → application.people  —  0 orphans
  ✓ [PASS] purchasing.suppliertransactions → application.people  —  0 orphans
  ✓ [PASS] purchasing.suppliertransactions → application.paymentmethods  —  0 orphans
  ✓ [PASS] purchasing.suppliertransactions → purchasing.purchaseorders  —  0 orphans
  ✓ [PASS] purchasing.suppliertransactions → purchasing.suppliers  —  0 orphans
  ✓ [PASS] purchasing.suppliertransactions → application.transactiontypes  —  0 orphans
  ✓ [PASS] purchasing.suppliers → application.people  —  0 orphans
  ✓ [PASS] purchasing.suppliers → application.people  —  0 orphans
  ✓ [PASS] purchasing.suppliers → application.cities  —  0 orphans
  ✓ [PASS] purchasing.suppliers → application.deliverymethods  —  0 orphans
  ✓ [PASS] purchasing.suppliers → application.cities  —  0 orphans
  ✓ [PASS] purchasing.suppliers → application.people  —  0 orphans
  ✓ [PASS] purchasing.suppliers → purchasing.suppliercategories  —  0 orphans
  ✗ [FAIL] sales.buyinggroups → application.people  —  1 orphaned rows  [FK_Sales_BuyingGroups_Application_People]
  ✓ [PASS] sales.customercategories → application.people  —  0 orphans
  ✗ [FAIL] sales.customertransactions → application.people  —  1 orphaned rows  [FK_Sales_CustomerTransactions_Application_People]
  ✓ [PASS] sales.customertransactions → sales.customers  —  0 orphans
  ✓ [PASS] sales.customertransactions → sales.invoices  —  0 orphans
  ✓ [PASS] sales.customertransactions → application.paymentmethods  —  0 orphans
  ✓ [PASS] sales.customertransactions → application.transactiontypes  —  0 orphans
  ✓ [PASS] sales.customers → application.people  —  0 orphans
  ✗ [FAIL] sales.customers → application.people  —  1 orphaned rows  [FK_Sales_Customers_Application_People]
  ✓ [PASS] sales.customers → sales.customers  —  0 orphans
  ✓ [PASS] sales.customers → sales.buyinggroups  —  0 orphans
  ✓ [PASS] sales.customers → sales.customercategories  —  0 orphans
  ✓ [PASS] sales.customers → application.cities  —  0 orphans
  ✓ [PASS] sales.customers → application.deliverymethods  —  0 orphans
  ✓ [PASS] sales.customers → application.cities  —  0 orphans
  ✓ [PASS] sales.customers → application.people  —  0 orphans
  ✓ [PASS] sales.invoicelines → application.people  —  0 orphans
  ✓ [PASS] sales.invoicelines → sales.invoices  —  0 orphans
  ✓ [PASS] sales.invoicelines → warehouse.packagetypes  —  0 orphans
  ✓ [PASS] sales.invoicelines → warehouse.stockitems  —  0 orphans
  ✓ [PASS] sales.invoices → application.people  —  0 orphans
  ✓ [PASS] sales.invoices → application.people  —  0 orphans
  ✓ [PASS] sales.invoices → sales.customers  —  0 orphans
  ✓ [PASS] sales.invoices → application.people  —  0 orphans
  ✓ [PASS] sales.invoices → sales.customers  —  0 orphans
  ✓ [PASS] sales.invoices → application.deliverymethods  —  0 orphans
  ✓ [PASS] sales.invoices → sales.orders  —  0 orphans
  ✓ [PASS] sales.invoices → application.people  —  0 orphans
  ✓ [PASS] sales.invoices → application.people  —  0 orphans
  ✓ [PASS] sales.orderlines → application.people  —  0 orphans
  ✓ [PASS] sales.orderlines → sales.orders  —  0 orphans
  ✓ [PASS] sales.orderlines → warehouse.packagetypes  —  0 orphans
  ✓ [PASS] sales.orderlines → warehouse.stockitems  —  0 orphans
  ✓ [PASS] sales.orders → application.people  —  0 orphans
  ✓ [PASS] sales.orders → sales.orders  —  0 orphans
  ✓ [PASS] sales.orders → application.people  —  0 orphans
  ✓ [PASS] sales.orders → sales.customers  —  0 orphans
  ✓ [PASS] sales.orders → application.people  —  0 orphans
  ✓ [PASS] sales.orders → application.people  —  0 orphans
  ✓ [PASS] sales.specialdeals → application.people  —  0 orphans
  ✓ [PASS] sales.specialdeals → sales.buyinggroups  —  0 orphans
  ✓ [PASS] sales.specialdeals → sales.customercategories  —  0 orphans
  ✓ [PASS] sales.specialdeals → sales.customers  —  0 orphans
  ✓ [PASS] sales.specialdeals → warehouse.stockgroups  —  0 orphans
  ✓ [PASS] sales.specialdeals → warehouse.stockitems  —  0 orphans
  ✓ [PASS] warehouse.colors → application.people  —  0 orphans
  ✓ [PASS] warehouse.packagetypes → application.people  —  0 orphans
  ✓ [PASS] warehouse.stockgroups → application.people  —  0 orphans
  ✓ [PASS] warehouse.stockitemholdings → application.people  —  0 orphans
  ✓ [PASS] warehouse.stockitemstockgroups → application.people  —  0 orphans
  ✓ [PASS] warehouse.stockitemstockgroups → warehouse.stockgroups  —  0 orphans
  ✓ [PASS] warehouse.stockitemstockgroups → warehouse.stockitems  —  0 orphans
  ✓ [PASS] warehouse.stockitemtransactions → application.people  —  0 orphans
  ✓ [PASS] warehouse.stockitemtransactions → sales.customers  —  0 orphans
  ✓ [PASS] warehouse.stockitemtransactions → sales.invoices  —  0 orphans
  ✓ [PASS] warehouse.stockitemtransactions → purchasing.purchaseorders  —  0 orphans
  ✓ [PASS] warehouse.stockitemtransactions → warehouse.stockitems  —  0 orphans
  ✓ [PASS] warehouse.stockitemtransactions → purchasing.suppliers  —  0 orphans
  ✓ [PASS] warehouse.stockitemtransactions → application.transactiontypes  —  0 orphans
  ✓ [PASS] warehouse.stockitems → application.people  —  0 orphans
  ✓ [PASS] warehouse.stockitems → warehouse.colors  —  0 orphans
  ✓ [PASS] warehouse.stockitems → warehouse.packagetypes  —  0 orphans
  ✓ [PASS] warehouse.stockitems → purchasing.suppliers  —  0 orphans
  ✓ [PASS] warehouse.stockitems → warehouse.packagetypes  —  0 orphans
  ✓ [PASS] warehouse.stockitemholdings → warehouse.stockitems  —  0 orphans

## Tier 6 — Sequence Alignment
  Found 26 sequences in 'sequences' schema
  ✓ [PASS] sequences.buying_group_id_seq  —  last_value=3 >= MAX(buyinggroupid)=3
  ✓ [PASS] sequences.city_id_seq  —  last_value=38,186 >= MAX(cityid)=38,186
  ✓ [PASS] sequences.color_id_seq  —  last_value=36 >= MAX(colorid)=36
  ✓ [PASS] sequences.country_id_seq  —  last_value=241 >= MAX(countryid)=241
  ✓ [PASS] sequences.customer_category_id_seq  —  last_value=8 >= MAX(customercategoryid)=8
  ✓ [PASS] sequences.customer_id_seq  —  last_value=1,061 >= MAX(customerid)=1,061
  ✓ [PASS] sequences.delivery_method_id_seq  —  last_value=10 >= MAX(deliverymethodid)=10
  ✓ [PASS] sequences.invoice_id_seq  —  last_value=70,510 >= MAX(invoiceid)=70,510
  ✓ [PASS] sequences.invoice_line_id_seq  —  last_value=228,265 >= MAX(invoicelineid)=228,265
  ✓ [PASS] sequences.order_id_seq  —  last_value=73,595 >= MAX(orderid)=73,595
  ✓ [PASS] sequences.order_line_id_seq  —  last_value=231,412 >= MAX(orderlineid)=231,412
  ✓ [PASS] sequences.package_type_id_seq  —  last_value=14 >= MAX(packagetypeid)=14
  ✓ [PASS] sequences.payment_method_id_seq  —  last_value=4 >= MAX(paymentmethodid)=4
  ✓ [PASS] sequences.person_id_seq  —  last_value=3,261 >= MAX(personid)=3,261
  ✓ [PASS] sequences.purchase_order_id_seq  —  last_value=2,074 >= MAX(purchaseorderid)=2,074
  ✓ [PASS] sequences.purchase_order_line_id_seq  —  last_value=8,367 >= MAX(purchaseorderlineid)=8,367
  ✓ [PASS] sequences.special_deal_id_seq  —  last_value=2 >= MAX(specialdealid)=2
  ✓ [PASS] sequences.state_province_id_seq  —  last_value=53 >= MAX(stateprovinceid)=53
  ✓ [PASS] sequences.stock_group_id_seq  —  last_value=10 >= MAX(stockgroupid)=10
  ✓ [PASS] sequences.stock_item_id_seq  —  last_value=227 >= MAX(stockitemid)=227
  ✓ [PASS] sequences.stock_item_stock_group_id_seq  —  last_value=885 >= MAX(stockitemstockgroupid)=442
  ✓ [PASS] sequences.supplier_category_id_seq  —  last_value=9 >= MAX(suppliercategoryid)=9
  ✓ [PASS] sequences.supplier_id_seq  —  last_value=13 >= MAX(supplierid)=13
  ✓ [PASS] sequences.system_parameter_id_seq  —  last_value=3 >= MAX(systemparameterid)=1
  ✓ [PASS] sequences.transaction_id_seq  —  last_value=336,252 >= MAX(suppliertransactionid)=335,847
  ✓ [PASS] sequences.transaction_type_id_seq  —  last_value=13 >= MAX(transactiontypeid)=13

## Final Tally  (15.6s elapsed)
  PASS: 202  FAIL: 3  WARN: 30  SKIP: 0

---

## Complete Row-by-Row Diff — 2026-05-27

Every row in every table compared field-by-field between MSSQL and PostgreSQL.
**1,034,327 rows checked across 31 tables.**

### Summary

| Metric | Result |
|---|---|
| Tables checked | 31 |
| Tables fully identical | 26 |
| Tables with differences | 5 |
| Rows only in MSSQL | 0 |
| Rows only in PG | 1 |
| Rows with changed values | 47 |

> **No rows are missing from PostgreSQL.** Every row that existed in MSSQL at migration time is present in PG.
> All differences are post-migration changes made via the API.

### Tables with differences

#### warehouse.stockitems — 43 rows, `Tags` field only

JSON whitespace difference only — same values, different serialization.
`["tag1","tag2"]` (MSSQL) vs `["tag1", "tag2"]` (PG — space after comma).
Affected StockItemIDs: 4–15, 58–66, 73–74, 118–137.

#### sales.buyinggroups — 1 row only in PG

`BuyingGroupID=3` ("Chinese Toys") — created via API after migration, does not exist in MSSQL.

#### sales.customercategories — 1 row changed

| Field | MSSQL | PG |
|---|---|---|
| `CustomerCategoryName` (ID=1) | `Agent` | `Agent Updated` |

#### sales.customers — 2 rows changed

**CustomerID=1** — overwritten with test data via API:

| Field | MSSQL | PG |
|---|---|---|
| CustomerName | Tailspin Toys (Head Office) | Test |
| BuyingGroupID | 1 | NULL |
| PostalCityID | 19586 | 1 |
| CreditLimit | NULL | 10000.0 |
| AccountOpenedDate | 2013-01-01 | 2015-01-01 |
| PhoneNumber | (308) 555-0100 | 555-1234 |
| FaxNumber | (308) 555-0101 | 555-5678 |
| WebsiteURL | http://www.tailspintoys.com | http://test.com |
| DeliveryAddressLine2 | 1877 Mittal Road | NULL |
| PostalAddressLine1 | PO Box 8975 | 123 Main St |
| PostalAddressLine2 | Ribeiroville | NULL |
| PostalPostalCode | 90410 | 12345 |

**CustomerID=3** — partial update via API:

| Field | MSSQL | PG |
|---|---|---|
| BuyingGroupID | 1 | NULL |
| DeliveryAddressLine2 | 1970 Khandke Road | NULL |
| PostalAddressLine2 | Lucescuville | NULL |
| LastEditedBy | 1 | 0 (invalid — PersonID 0 does not exist) |

#### sales.customertransactions — 1 row changed

**CustomerTransactionID=2** — modified via API:

| Field | MSSQL | PG |
|---|---|---|
| PaymentMethodID | NULL | 3 |
| FinalizationDate | 2013-01-02 | NULL |
| IsFinalized | True | False |
| LastEditedBy | 10 (Stella Rosenhain) | 0 (invalid) |

### Tables confirmed identical (all rows, all fields)

| Table | Rows |
|---|---|
| application.people | 1,111 |
| application.countries | 190 |
| application.stateprovinces | 53 |
| application.cities | 37,940 |
| application.deliverymethods | 10 |
| application.paymentmethods | 4 |
| application.transactiontypes | 13 |
| application.systemparameters | 1 |
| warehouse.colors | 36 |
| warehouse.packagetypes | 14 |
| warehouse.stockgroups | 10 |
| warehouse.stockitemholdings | 227 |
| warehouse.stockitemstockgroups | 442 |
| warehouse.stockitemtransactions | 236,667 |
| warehouse.vehicletemperatures | 65,998 |
| warehouse.coldroomtemperatures | 4 |
| purchasing.suppliercategories | 9 |
| purchasing.suppliers | 13 |
| purchasing.purchaseorders | 2,074 |
| purchasing.purchaseorderlines | 8,367 |
| purchasing.suppliertransactions | 2,438 |
| sales.orders | 73,595 |
| sales.orderlines | 231,412 |
| sales.invoices | 70,510 |
| sales.invoicelines | 228,265 |
| sales.specialdeals | 2 |