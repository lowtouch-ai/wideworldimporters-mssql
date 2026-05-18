# pgtable-test report: Application.DeliveryMethods

## Source
- **Table file:** `postgres/Application/Tables/DeliveryMethods.sql`
- **Test run:** 2026-05-18

## Dependencies
| Dependency | Status | Notes |
|---|---|---|
| `application.people` | ✓ Applied (FK stripped) | `postgres/Application/Tables/People.sql` |

## Sequences
| Sequence | Status |
|---|---|
| `sequences.delivery_method_id_seq` | ✓ Created (START 11) |

## Result
- Table load: ✓ Success
- SELECT LIMIT 0: ✓ ok
- Columns verified: 5

## Column inventory
| Column | Type |
|---|---|
| `deliverymethodid` | integer |
| `deliverymethodname` | character varying |
| `lasteditedby` | integer |
| `validfrom` | timestamp without time zone |
| `validto` | timestamp without time zone |
