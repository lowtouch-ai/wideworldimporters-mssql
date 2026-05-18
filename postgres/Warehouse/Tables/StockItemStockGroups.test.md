# pgtable-test report: Warehouse.StockItemStockGroups

## Source
- **Table file:** `postgres/Warehouse/Tables/StockItemStockGroups.sql`
- **Test run:** 2026-05-19

## Dependencies
| Dependency | Status | Notes |
|---|---|---|
| `application.people` | ✓ Applied (FK stripped) | `postgres/Application/Tables/People.sql` |
| `warehouse.stockgroups` | ✓ Applied (FK stripped) | `postgres/Warehouse/Tables/StockGroups.sql` |
| `warehouse.stockitems` | ✓ Applied (FK stripped) | `postgres/Warehouse/Tables/StockItems.sql` |

## Sequences
| Sequence | Status |
|---|---|
| `sequences.stock_item_stock_group_id_seq` | ✓ Created |

## Result
- Table load: ✓ Success
- SELECT LIMIT 0: ✓ ok
- Columns verified: 5

## Column inventory
| Column | Type |
|---|---|
| `StockItemStockGroupID` | integer |
| `StockItemID` | integer |
| `StockGroupID` | integer |
| `LastEditedBy` | integer |
| `LastEditedWhen` | timestamp without time zone |

## Next steps
- Continue with: `/pgtable-test postgres/Sales/Tables/Customers.sql`
