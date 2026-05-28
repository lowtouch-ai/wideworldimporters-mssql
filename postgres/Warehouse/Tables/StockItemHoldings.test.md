# pgtable-test report: Warehouse.StockItemHoldings

## Source
- **Table file:** `postgres/Warehouse/Tables/StockItemHoldings.sql`
- **Test run:** 2026-05-19

## Dependencies
| Dependency | Status | Notes |
|---|---|---|
| `application.people` | ✓ Applied (FK stripped) | `postgres/Application/Tables/People.sql` |
| `warehouse.stockitems` | ✓ Applied (FK stripped) | `postgres/Warehouse/Tables/StockItems.sql` |

## Sequences
| Sequence | Status |
|---|---|
| None | — |

## Result
- Table load: ✓ Success
- SELECT LIMIT 0: ✓ ok
- Columns verified: 9

## Column inventory
| Column | Type |
|---|---|
| `StockItemID` | integer |
| `QuantityOnHand` | integer |
| `BinLocation` | character varying |
| `LastStocktakeQuantity` | integer |
| `LastCostPrice` | numeric |
| `ReorderLevel` | integer |
| `TargetStockLevel` | integer |
| `LastEditedBy` | integer |
| `LastEditedWhen` | timestamp without time zone |

## Next steps
- Continue with: `/pgtable-test postgres/Warehouse/Tables/StockItemStockGroups.sql`
