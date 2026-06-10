# vehicle_temperatures (view)

Converted from: `wwi-ssdt/wwi-ssdt/Website/Views/VehicleTemperatures.sql`

## Summary

View over `warehouse.vehicletemperatures` that decompresses sensor data on the fly for compressed records.

## Conversion notes

- `CAST(DECOMPRESS(vt.CompressedSensorData) AS nvarchar(1000))` — `DECOMPRESS()` is a MSSQL-specific function to decompress GZIP-compressed `varbinary`. No direct PostgreSQL equivalent.
  - **TODO**: If data is stored as gzip-compressed bytea, use a custom function or the `pg_decompress` extension. For now, returns `NULL` for compressed records.
- `IsCompressed <> 0` → `vt.IsCompressed` (boolean)

## TODOs

- Decide on compression strategy: if `CompressedSensorData` is migrated as `bytea` with gzip content, implement a PL/Python or PL/Perl decompression function, or decompress at ETL time.

## Dependencies

| Object | Status |
|---|---|
| `warehouse.vehicletemperatures` | check postgres/Warehouse/Tables/VehicleTemperatures.sql |
