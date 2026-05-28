# pgtable-test report: Warehouse.VehicleTemperatures

## Source
- **Table file:** `postgres/Warehouse/Tables/VehicleTemperatures.sql`
- **Test run:** 2026-05-18T19:20:22Z

## Dependencies
None — no foreign key references.

## Sequences
None (uses GENERATED ALWAYS AS IDENTITY for PK).

## Result
- Table load: ✓ Success
- SELECT LIMIT 0: ✓ ok
- Columns verified: 8

## Column inventory
| Column | Type |
|---|---|
| `VehicleTemperatureID` | bigint |
| `VehicleRegistration` | character varying |
| `ChillerSensorNumber` | integer |
| `RecordedWhen` | timestamp without time zone |
| `Temperature` | numeric |
| `FullSensorData` | character varying |
| `IsCompressed` | boolean |
| `CompressedSensorData` | bytea |

## TODOs
- MEMORY_OPTIMIZED stripped — application concurrency managed at application level.
- COLLATE Latin1_General_CI_AS stripped; database default collation used.
