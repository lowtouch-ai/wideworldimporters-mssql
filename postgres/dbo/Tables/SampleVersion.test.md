# pgtable-test report: dbo.SampleVersion

## Source
- **Table file:** `postgres/dbo/Tables/SampleVersion.sql`
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
| `MajorSampleVersion` | integer |
| `MinorSampleVersion` | integer |
| `MinSQLServerBuild` | character varying |
| `RowCount` | integer |

## TODOs
None.
