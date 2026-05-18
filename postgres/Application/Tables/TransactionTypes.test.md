# pgtable-test report: Application.TransactionTypes

## Source
- **Table file:** `postgres/Application/Tables/TransactionTypes.sql`
- **Test run:** 2026-05-18

## Dependencies
| Dependency | Status | Notes |
|---|---|---|
| `application.people` | ✓ Applied (FK stripped) | `postgres/Application/Tables/People.sql` |

## Sequences
| Sequence | Status |
|---|---|
| `sequences.transaction_type_id_seq` | ✓ Created (START 15) |

## Result
- Table load: ✓ Success
- Columns verified: 5

## Column inventory
| Column | Type |
|---|---|
| `transactiontypeid` | integer |
| `transactiontypename` | character varying |
| `lasteditedby` | integer |
| `validfrom` | timestamp without time zone |
| `validto` | timestamp without time zone |
