# pgtable-test report: Warehouse.StockItems_Archive

## Source
- **Table file:** `postgres/Warehouse/Tables/StockItems_Archive.sql`
- **Test run:** 2026-05-19

## Dependencies
| Dependency | Status | Notes |
|---|---|---|
| None | — | Archive table; no foreign keys |

## Sequences
| Sequence | Status |
|---|---|
| None | — |

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

## Next steps
- Continue with: `/pgtable-test postgres/Warehouse/Tables/StockItemHoldings.sql`
