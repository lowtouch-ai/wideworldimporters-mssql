# pgtable-test report: Application.StateProvinces_Archive

## Source
- **Table file:** `postgres/Application/Tables/StateProvinces_Archive.sql`
- **Test run:** 2026-05-18

## Dependencies
None (archive table)

## Extensions
| Extension | Status |
|---|---|
| `postgis` | ✓ Installed (postgresql-15-postgis-3) |

## Result
- Table load: ✓ Success
- Columns verified: 10

## Column inventory
| Column | Type |
|---|---|
| `stateprovinceid` | integer |
| `stateprovincecode` | character varying |
| `stateprovincename` | character varying |
| `countryid` | integer |
| `salesterritory` | character varying |
| `border` | geography ✓ |
| `latestrecordedpopulation` | bigint |
| `lasteditedby` | integer |
| `validfrom` | timestamp without time zone |
| `validto` | timestamp without time zone |
