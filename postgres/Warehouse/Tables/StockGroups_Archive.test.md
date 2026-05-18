# pgtable-test report: Warehouse.StockGroups_Archive

## Source
- **Table file:** `postgres/Warehouse/Tables/StockGroups_Archive.sql`
- **Test run:** 2026-05-18

## Dependencies
No FK dependencies.

## Result
- Table load: ✓ Success
- SELECT LIMIT 0: ✓ ok
- Columns verified: 5

## Column inventory
| Column | Type |
|---|---|
| `StockGroupID` | integer |
| `StockGroupName` | character varying |
| `LastEditedBy` | integer |
| `ValidFrom` | timestamp without time zone |
| `ValidTo` | timestamp without time zone |
