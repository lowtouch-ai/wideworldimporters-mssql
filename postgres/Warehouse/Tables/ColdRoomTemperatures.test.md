# pgtable-test report: Warehouse.ColdRoomTemperatures

## Source
- **Table file:** `postgres/Warehouse/Tables/ColdRoomTemperatures.sql`
- **Test run:** 2026-05-18T19:20:22Z

## Dependencies
None — no foreign key references.

## Sequences
None (uses GENERATED ALWAYS AS IDENTITY for PK).

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
- MEMORY_OPTIMIZED and SYSTEM_VERSIONING stripped — temporal audit history requires separate trigger or pg_audit strategy.
- ValidFrom/ValidTo are plain columns with DEFAULT CURRENT_TIMESTAMP; application must populate them explicitly if temporal tracking is needed.
