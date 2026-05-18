# pgtable-test report: Purchasing.SupplierCategories

## Source
- **Table file:** `postgres/Purchasing/Tables/SupplierCategories.sql`
- **Test run:** 2026-05-18

## Dependencies
| Dependency | Status | Notes |
|---|---|---|
| `application.people` | ✓ Applied (FK stripped) | `postgres/Application/Tables/People.sql` |

## Sequences
| Sequence | Status |
|---|---|
| `sequences.supplier_category_id_seq` | ✓ Created |

## Result
- Table load: ✓ Success
- SELECT LIMIT 0: ✓ ok
- Columns verified: 5

## Column inventory
| Column | Type |
|---|---|
| `SupplierCategoryID` | integer |
| `SupplierCategoryName` | character varying |
| `LastEditedBy` | integer |
| `ValidFrom` | timestamp without time zone |
| `ValidTo` | timestamp without time zone |
