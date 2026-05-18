# pgtable-test report: Warehouse.ColdRoomTemperatures_Archive

## Source
- **Table file:** `postgres/Warehouse/Tables/ColdRoomTemperatures_Archive.sql`
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
- DATA_COMPRESSION = PAGE stripped (no PostgreSQL equivalent).
