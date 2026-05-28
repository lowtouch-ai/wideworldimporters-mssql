# pgtable-test report: Warehouse.StockItems

## Source
- **Table file:** `postgres/Warehouse/Tables/StockItems.sql`
- **Test run:** 2026-05-19

## Dependencies
| Dependency | Status | Notes |
|---|---|---|
| `application.people` | ✓ Applied (FK stripped) | `postgres/Application/Tables/People.sql` |
| `warehouse.colors` | ✓ Applied (FK stripped) | `postgres/Warehouse/Tables/Colors.sql` |
| `warehouse.packagetypes` | ✓ Applied (FK stripped) | `postgres/Warehouse/Tables/PackageTypes.sql` |
| `purchasing.suppliers` | ✓ Applied (FK stripped) | `postgres/Purchasing/Tables/Suppliers.sql` |

## Sequences
| Sequence | Status |
|---|---|
| `sequences.stock_item_id_seq` | ✓ Created |

## Result
- Table load: ✓ Success
- SELECT LIMIT 0: ✓ ok
- Columns verified: 25

## Column inventory
| Column | Type |
|---|---|
| `StockItemID` | integer |
| `StockItemName` | character varying |
| `SupplierID` | integer |
| `ColorID` | integer |
| `UnitPackageID` | integer |
| `OuterPackageID` | integer |
| `Brand` | character varying |
| `Size` | character varying |
| `LeadTimeDays` | integer |
| `QuantityPerOuter` | integer |
| `IsChillerStock` | boolean |
| `Barcode` | character varying |
| `TaxRate` | numeric |
| `UnitPrice` | numeric |
| `RecommendedRetailPrice` | numeric |
| `TypicalWeightPerUnit` | numeric |
| `MarketingComments` | text |
| `InternalComments` | text |
| `Photo` | bytea |
| `CustomFields` | text |
| `Tags` | text |
| `SearchDetails` | text |
| `LastEditedBy` | integer |
| `ValidFrom` | timestamp without time zone |
| `ValidTo` | timestamp without time zone |

## TODOs
- `Tags`: was a non-persisted computed column (json_query on CustomFields.Tags)
- `SearchDetails`: was a non-persisted computed column (concat of StockItemName + MarketingComments)
- `ValidFrom`/`ValidTo`: were temporal system-time columns; converted to plain timestamps

## Next steps
- Continue with: `/pgtable-test postgres/Warehouse/Tables/StockItems_Archive.sql`
