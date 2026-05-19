# pgtable-test report: DataLoadSimulation.SeasonVariation

## Source
- **Table file:** `postgres/DataLoadSimulation/Tables/SeasonVariation.sql`
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
| `Year` | integer |
| `Season` | smallint |
| `YearlyVariation` | double precision |
| `SeasonalVariation` | double precision |

## TODOs
None.
