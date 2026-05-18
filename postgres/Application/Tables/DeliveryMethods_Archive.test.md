# pgtable-test report: Application.DeliveryMethods_Archive

## Source
- **Table file:** `postgres/Application/Tables/DeliveryMethods_Archive.sql`
- **Test run:** 2026-05-18

## Dependencies
None (archive table)

## Result
- Table load: ✓ Success
- Columns verified: 5

## Column inventory
| Column | Type |
|---|---|
| `deliverymethodid` | integer |
| `deliverymethodname` | character varying |
| `lasteditedby` | integer |
| `validfrom` | timestamp without time zone |
| `validto` | timestamp without time zone |
