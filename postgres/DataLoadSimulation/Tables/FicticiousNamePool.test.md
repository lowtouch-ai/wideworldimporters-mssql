# pgtable-test report: DataLoadSimulation.FicticiousNamePool

## Source
- **Table file:** `postgres/DataLoadSimulation/Tables/FicticiousNamePool.sql`
- **Test run:** 2026-05-18T19:20:22Z

## Dependencies
None — no foreign key references.

## Sequences
None.

## Result
- Table load: ✓ Success
- SELECT LIMIT 0: ✓ ok
- Columns verified: 4

## Column inventory
| Column | Type |
|---|---|
| `FullName` | character varying |
| `PreferredName` | character varying |
| `LastName` | character varying |
| `ToEmail` | character varying |

## TODOs
None.
