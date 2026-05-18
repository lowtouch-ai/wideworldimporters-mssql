# pgtable-test report: Purchasing.Suppliers

## Source
- **Table file:** `postgres/Purchasing/Tables/Suppliers.sql`
- **Test run:** 2026-05-18

## Dependencies
| Dependency | Status | Notes |
|---|---|---|
| `application.people` | ✓ Applied (FK stripped) | `postgres/Application/Tables/People.sql` |
| `application.cities` | ✓ Applied (FK stripped) | `postgres/Application/Tables/Cities.sql` |
| `application.delivery_methods` | ✓ Applied (FK stripped) | `postgres/Application/Tables/DeliveryMethods.sql` |
| `purchasing.supplier_categories` | ✓ Applied (FK stripped) | `postgres/Purchasing/Tables/SupplierCategories.sql` |

## Sequences
| Sequence | Status |
|---|---|
| `sequences.supplier_id_seq` | ✓ Created |

## Extensions
| Extension | Status |
|---|---|
| `postgis` | ✓ Already installed |

## Result
- Table load: ✓ Success
- SELECT LIMIT 0: ✓ ok
- Columns verified: 29

## Column inventory
| Column | Type |
|---|---|
| `SupplierID` | integer |
| `SupplierName` | character varying |
| `SupplierCategoryID` | integer |
| `PrimaryContactPersonID` | integer |
| `AlternateContactPersonID` | integer |
| `DeliveryMethodID` | integer |
| `DeliveryCityID` | integer |
| `PostalCityID` | integer |
| `SupplierReference` | character varying |
| `BankAccountName` | character varying |
| `BankAccountBranch` | character varying |
| `BankAccountCode` | character varying |
| `BankAccountNumber` | character varying |
| `BankInternationalCode` | character varying |
| `PaymentDays` | integer |
| `InternalComments` | text |
| `PhoneNumber` | character varying |
| `FaxNumber` | character varying |
| `WebsiteURL` | character varying |
| `DeliveryAddressLine1` | character varying |
| `DeliveryAddressLine2` | character varying |
| `DeliveryPostalCode` | character varying |
| `DeliveryLocation` | USER-DEFINED (geography/PostGIS) |
| `PostalAddressLine1` | character varying |
| `PostalAddressLine2` | character varying |
| `PostalPostalCode` | character varying |
| `LastEditedBy` | integer |
| `ValidFrom` | timestamp without time zone |
| `ValidTo` | timestamp without time zone |
