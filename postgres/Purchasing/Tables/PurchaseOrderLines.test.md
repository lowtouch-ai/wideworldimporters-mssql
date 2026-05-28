# pgtable-test report: Purchasing.PurchaseOrderLines

## Source
- **Table file:** `postgres/Purchasing/Tables/PurchaseOrderLines.sql`
- **Test run:** 2026-05-19

## Dependencies
| Dependency | Status | Notes |
|---|---|---|
| `application.people` | ✓ Applied (FK stripped) | `postgres/Application/Tables/People.sql` |
| `warehouse.packagetypes` | ✓ Applied (FK stripped) | `postgres/Warehouse/Tables/PackageTypes.sql` |
| `purchasing.purchaseorders` | ✓ Applied (FK stripped) | `postgres/Purchasing/Tables/PurchaseOrders.sql` |
| `warehouse.stockitems` | ✓ Applied (FK stripped) | `postgres/Warehouse/Tables/StockItems.sql` |

## Sequences
| Sequence | Status |
|---|---|
| `sequences.purchase_order_line_id_seq` | ✓ Created |

## Result
- Table load: ✓ Success
- SELECT LIMIT 0: ✓ ok
- Columns verified: 12

## Column inventory
| Column | Type |
|---|---|
| `PurchaseOrderLineID` | integer |
| `PurchaseOrderID` | integer |
| `StockItemID` | integer |
| `OrderedOuters` | integer |
| `Description` | character varying |
| `ReceivedOuters` | integer |
| `PackageTypeID` | integer |
| `ExpectedUnitPricePerOuter` | numeric |
| `LastReceiptDate` | date |
| `IsOrderLineFinalized` | boolean |
| `LastEditedBy` | integer |
| `LastEditedWhen` | timestamp without time zone |

## Next steps
- Continue with: `/pgtable-test postgres/Sales/Tables/SpecialDeals.sql`
