# pgtable-test report: Application.Countries_Archive

## Source
- **Table file:** `postgres/Application/Tables/Countries_Archive.sql`
- **Test run:** 2026-05-18

## Dependencies
None (archive table — no FK constraints)

## Extensions
| Extension | Status |
|---|---|
| `postgis` | ✓ Installed (postgresql-15-postgis-3) |

## Result
- Table load: ✓ Success
- Columns verified: 14

## Column inventory
| Column | Type |
|---|---|
| `countryid` | integer |
| `countryname` | character varying |
| `formalname` | character varying |
| `isoalpha3code` | character varying |
| `isonumericcode` | integer |
| `countrytype` | character varying |
| `latestrecordedpopulation` | bigint |
| `continent` | character varying |
| `region` | character varying |
| `subregion` | character varying |
| `border` | geography ✓ |
| `lasteditedby` | integer |
| `validfrom` | timestamp without time zone |
| `validto` | timestamp without time zone |
