# pgtable-test report: DataLoadSimulation.ColdRoomTemperatures_temp

## Source
- **Table file:** `postgres/DataLoadSimulation/Tables/ColdRoomTemperatures_temp.sql`
- **Test run:** 2026-05-18T19:20:22Z

## Dependencies
None — no foreign key references.

## Sequences
None.

## Result
- Table load: ✓ Success
- SELECT LIMIT 0: ✓ ok
- Columns verified: 6

## Column inventory
| Column | Type |
|---|---|
| `ColdRoomTemperatureID` | bigint |
| `ColdRoomSensorNumber` | integer |
| `RecordedWhen` | timestamp without time zone |
| `Temperature` | numeric |
| `ValidFrom` | timestamp without time zone |
| `ValidTo` | timestamp without time zone |

## TODOs
- MEMORY_OPTIMIZED and HASH index stripped — application must handle concurrent access differently if needed.
