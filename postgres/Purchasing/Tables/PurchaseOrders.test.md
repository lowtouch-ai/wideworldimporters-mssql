# pgtable-test report: Purchasing.PurchaseOrders

## Source
- **Table file:** `postgres/Purchasing/Tables/PurchaseOrders.sql`
- **Test run:** 2026-05-19

## Dependencies
| Dependency | Status | Notes |
|---|---|---|
| `application.people` | ✓ Applied (FK stripped) | `postgres/Application/Tables/People.sql` |
| `application.deliverymethods` | ✓ Applied (FK stripped) | `postgres/Application/Tables/DeliveryMethods.sql` |
| `purchasing.suppliers` | ✓ Applied (FK stripped) | `postgres/Purchasing/Tables/Suppliers.sql` |

## Sequences
| Sequence | Status |
|---|---|
| `sequences.purchase_order_id_seq` | ✓ Created |

## Result
- Table load: ✓ Success
- SELECT LIMIT 0: ✓ ok
- Columns verified: 12

## Column inventory
| Column | Type |
|---|---|
| `PurchaseOrderID` | integer |
| `SupplierID` | integer |
| `OrderDate` | date |
| `DeliveryMethodID` | integer |
| `ContactPersonID` | integer |
| `ExpectedDeliveryDate` | date |
| `SupplierReference` | character varying |
| `IsOrderFinalized` | boolean |
| `Comments` | text |
| `InternalComments` | text |
| `LastEditedBy` | integer |
| `LastEditedWhen` | timestamp without time zone |

## Next steps
- Continue with: `/pgtable-test postgres/Purchasing/Tables/PurchaseOrderLines.sql`
