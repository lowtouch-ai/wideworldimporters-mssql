# Migration Validation Report — 2026-05-22

## Summary
- Tables checked: 31
- **PASS: 28**  FAIL: 3
- Elapsed: 4.6s

## Results

| Table | MSSQL rows | PG rows | Rows | PK min | PK max | Checksums | NULLs |
|-------|-----------|---------|------|--------|--------|-----------|-------|
| application.people | 1,111 | 1,111 | ✓ | ✓ | ✓ | ✓ | ✓ |
| application.countries | 190 | 190 | ✓ | ✓ | ✓ | ✓ | ✓ |
| application.stateprovinces | 53 | 53 | ✓ | ✓ | ✓ | ✓ | ✓ |
| application.cities | 37,940 | 37,940 | ✓ | ✓ | ✓ | ✓ | ✓ |
| application.deliverymethods | 10 | 10 | ✓ | ✓ | ✓ | ✓ | ✓ |
| application.paymentmethods | 4 | 4 | ✓ | ✓ | ✓ | ✓ | ✓ |
| application.transactiontypes | 13 | 13 | ✓ | ✓ | ✓ | ✓ | ✓ |
| application.systemparameters | 1 | 1 | ✓ | ✓ | ✓ | ✓ | ✓ |
| warehouse.colors | 36 | 36 | ✓ | ✓ | ✓ | ✓ | ✓ |
| warehouse.packagetypes | 14 | 14 | ✓ | ✓ | ✓ | ✓ | ✓ |
| warehouse.stockgroups | 10 | 10 | ✓ | ✓ | ✓ | ✓ | ✓ |
| purchasing.suppliercategories | 9 | 9 | ✓ | ✓ | ✓ | ✓ | ✓ |
| purchasing.suppliers | 13 | 13 | ✓ | ✓ | ✓ | ✓ | ✓ |
| sales.buyinggroups | 2 | 3 | ✗ | ✓ | ✗ | ✗(1) | ✓ |
| sales.customercategories | 8 | 8 | ✓ | ✓ | ✓ | ✓ | ✓ |
| sales.customers | 663 | 663 | ✓ | ✓ | ✓ | ✗(4) | ✗(6) |
| warehouse.stockitems | 227 | 227 | ✓ | ✓ | ✓ | ✓ | ✓ |
| warehouse.stockitemholdings | 227 | 227 | ✓ | ✓ | ✓ | ✓ | ✓ |
| warehouse.stockitemstockgroups | 442 | 442 | ✓ | ✓ | ✓ | ✓ | ✓ |
| purchasing.purchaseorders | 2,074 | 2,074 | ✓ | ✓ | ✓ | ✓ | ✓ |
| purchasing.purchaseorderlines | 8,367 | 8,367 | ✓ | ✓ | ✓ | ✓ | ✓ |
| purchasing.suppliertransactions | 2,438 | 2,438 | ✓ | ✓ | ✓ | ✓ | ✓ |
| sales.orders | 73,595 | 73,595 | ✓ | ✓ | ✓ | ✓ | ✓ |
| sales.orderlines | 231,412 | 231,412 | ✓ | ✓ | ✓ | ✓ | ✓ |
| sales.invoices | 70,510 | 70,510 | ✓ | ✓ | ✓ | ✓ | ✓ |
| sales.invoicelines | 228,265 | 228,265 | ✓ | ✓ | ✓ | ✓ | ✓ |
| sales.customertransactions | 97,147 | 97,147 | ✓ | ✓ | ✓ | ✗(2) | ✗(2) |
| sales.specialdeals | 2 | 2 | ✓ | ✓ | ✓ | ✓ | ✓ |
| warehouse.stockitemtransactions | 236,667 | 236,667 | ✓ | ✓ | ✓ | ✓ | ✓ |
| warehouse.vehicletemperatures | 65,998 | 65,998 | ✓ | ✓ | ✓ | ✓ | ✓ |
| warehouse.coldroomtemperatures | 4 | 4 | ✓ | ✓ | ✓ | ✓ | ✓ |

## Failures


### sales.buyinggroups
- Row count: MSSQL=2  PG=3
- PK max mismatch
- SUM(BuyingGroupID): MSSQL=3.0  PG=6.0

### sales.customers
- SUM(BuyingGroupID): MSSQL=603.0  PG=601.0
- SUM(PostalCityID): MSSQL=12618925.0  PG=12599340.0
- SUM(CreditLimit): MSSQL=682476.0  PG=692476.0
- SUM(LastEditedBy): MSSQL=1289.0  PG=1288.0
- NULL count (BuyingGroupID): MSSQL=261  PG=263
- NULL count (CreditLimit): MSSQL=402  PG=401
- NULL count (DeliveryRun): MSSQL=61  PG=63
- NULL count (RunPosition): MSSQL=61  PG=63
- NULL count (DeliveryAddressLine2): MSSQL=0  PG=2
- NULL count (PostalAddressLine2): MSSQL=0  PG=2

### sales.customertransactions
- SUM(PaymentMethodID): MSSQL=106548.0  PG=106551.0
- SUM(LastEditedBy): MSSQL=1062573.0  PG=1062563.0
- NULL count (PaymentMethodID): MSSQL=70510  PG=70509
- NULL count (FinalizationDate): MSSQL=84  PG=85

## Skipped Columns (geography/binary — migrated as NULL by design)
- application.people.HashedPassword
- application.people.Photo
- application.countries.Border
- application.stateprovinces.Border
- application.cities.Location
- application.systemparameters.DeliveryLocation
- purchasing.suppliers.DeliveryLocation
- sales.customers.DeliveryLocation
- warehouse.stockitems.Photo
- warehouse.vehicletemperatures.CompressedSensorData
