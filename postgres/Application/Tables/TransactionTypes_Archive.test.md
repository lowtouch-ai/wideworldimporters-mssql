# pgtable-test report: Application.TransactionTypes_Archive

## Source
- **Table file:** `postgres/Application/Tables/TransactionTypes_Archive.sql`
- **Test run:** 2026-05-18

## Dependencies
None (archive table)

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
