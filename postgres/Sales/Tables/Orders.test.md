# pgtable-test report: Sales.Orders

## Source
- **Table file:** `postgres/Sales/Tables/Orders.sql`
- **Test run:** 2026-05-18T19:20:22Z

## Dependencies
| Dependency | Status |
|---|---|
| `application.people` | ✓ Applied (pre-existing from Session 1) |
| `sales.customers` | ✓ Applied (pre-existing from Session 3) |
| `sales.orders` | ✓ Self-reference (same table) |

## Sequences
| Sequence | Status |
|---|---|
| `sequences.order_id_seq` | ✓ Created (pre-existing from Session 1) |

## Result
- Table load: ✓ Success (FK constraints stripped for test isolation)
- SELECT LIMIT 0: ✓ ok
- Columns verified: 16

## Column inventory
| Column | Type |
|---|---|
| `OrderID` | integer |
| `CustomerID` | integer |
| `SalespersonPersonID` | integer |
| `PickedByPersonID` | integer |
| `ContactPersonID` | integer |
| `BackorderOrderID` | integer |
| `OrderDate` | date |
| `ExpectedDeliveryDate` | date |
| `CustomerPurchaseOrderNumber` | character varying |
| `IsUndersupplyBackordered` | boolean |
| `Comments` | text |
| `DeliveryInstructions` | text |
| `InternalComments` | text |
| `PickingCompletedWhen` | timestamp without time zone |
| `LastEditedBy` | integer |
| `LastEditedWhen` | timestamp without time zone |

## TODOs
None.
