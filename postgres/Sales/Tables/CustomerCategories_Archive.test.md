# pgtable-test report: Sales.CustomerCategories_Archive

## Source
- **Table file:** `postgres/Sales/Tables/CustomerCategories_Archive.sql`
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
| `CustomerCategoryID` | integer |
| `CustomerCategoryName` | character varying |
| `LastEditedBy` | integer |
| `ValidFrom` | timestamp without time zone |
| `ValidTo` | timestamp without time zone |
