# pgtable-test report: Sales.BuyingGroups_Archive

## Source
- **Table file:** `postgres/Sales/Tables/BuyingGroups_Archive.sql`
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
| `BuyingGroupID` | integer |
| `BuyingGroupName` | character varying |
| `LastEditedBy` | integer |
| `ValidFrom` | timestamp without time zone |
| `ValidTo` | timestamp without time zone |
