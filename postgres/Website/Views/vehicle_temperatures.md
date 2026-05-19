# Conversion summary: Website.VehicleTemperatures

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Website/Views/VehicleTemperatures.sql`
- **Output:** `postgres/Website/Views/vehicle_temperatures.sql`

## Conversions applied
- `Website.VehicleTemperatures` → `website.vehicle_temperatures`
- `vt.IsCompressed <> 0` → `vt.IsCompressed = TRUE` (BIT → BOOLEAN)
- `CAST(DECOMPRESS(vt.CompressedSensorData) AS nvarchar(1000))` → `NULL` with TODO (see below)
- `Warehouse.VehicleTemperatures` → `warehouse.vehicletemperatures`

## TODOs
- `-- TODO: DECOMPRESS() has no direct PostgreSQL equivalent` — MSSQL's `DECOMPRESS()` function decompresses GZIP-compressed `VARBINARY` data (stored as `BYTEA` in PostgreSQL). PostgreSQL has no built-in equivalent. Options:
  - Implement a PL/pgSQL wrapper using a C extension or `pg_decompress` (if available)
  - Use the `lo_*` functions or a server-side function from a custom extension
  - Currently returns `NULL` for compressed rows; `FullSensorData` is returned as-is for uncompressed rows

## Table dependencies
| Table | Postgres file | Status |
|---|---|---|
| `warehouse.vehicletemperatures` | `postgres/Warehouse/Tables/VehicleTemperatures.sql` | ✓ converted |
