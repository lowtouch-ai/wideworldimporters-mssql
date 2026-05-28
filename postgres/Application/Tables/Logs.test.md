# pgtable-test report: Application.Logs

## Source
- **Table file:** `postgres/Application/Tables/Logs.sql`
- **Test run:** 2026-05-18

## Dependencies
None

## Result
- Table load: ✓ Success
- Columns verified: 4

## Column inventory
| Column | Type |
|---|---|
| `message` | character varying |
| `level` | character varying |
| `eventtime` | timestamp without time zone |
| `logevent` | text |

## TODOs
- CLUSTERED COLUMNSTORE INDEX (`CCX_Application_Logs`) was omitted — no PostgreSQL equivalent. Consider a regular BRIN or partial index if log query performance is needed.
