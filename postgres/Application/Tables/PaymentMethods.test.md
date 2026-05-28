# pgtable-test report: Application.PaymentMethods

## Source
- **Table file:** `postgres/Application/Tables/PaymentMethods.sql`
- **Test run:** 2026-05-18

## Dependencies
| Dependency | Status | Notes |
|---|---|---|
| `application.people` | ✓ Applied (FK stripped) | `postgres/Application/Tables/People.sql` |

## Sequences
| Sequence | Status |
|---|---|
| `sequences.payment_method_id_seq` | ✓ Created (START 5) |

## Result
- Table load: ✓ Success
- Columns verified: 5

## Column inventory
| Column | Type |
|---|---|
| `paymentmethodid` | integer |
| `paymentmethodname` | character varying |
| `lasteditedby` | integer |
| `validfrom` | timestamp without time zone |
| `validto` | timestamp without time zone |
