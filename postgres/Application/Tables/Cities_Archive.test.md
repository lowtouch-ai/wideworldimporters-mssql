# pgtable-test report: Application.Cities_Archive

## Source
- **Table file:** `postgres/Application/Tables/Cities_Archive.sql`
- **Test run:** 2026-05-18

## Dependencies
None (archive table)

## Extensions
| Extension | Status |
|---|---|
| `postgis` | ✓ Installed (postgresql-15-postgis-3) |

## Result
- Table load: ✓ Success
- Columns verified: 8

## Column inventory
| Column | Type |
|---|---|
| `cityid` | integer |
| `cityname` | character varying |
| `stateprovinceid` | integer |
| `location` | geography ✓ |
| `latestrecordedpopulation` | bigint |
| `lasteditedby` | integer |
| `validfrom` | timestamp without time zone |
| `validto` | timestamp without time zone |
