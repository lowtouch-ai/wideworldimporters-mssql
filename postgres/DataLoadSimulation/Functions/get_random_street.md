# Conversion summary: DataLoadSimulation.GetRandomStreet

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomStreet.sql`
- **Pattern:** Single OUTPUT parameter → RETURNS varchar(50)
- **Output:** `postgres/DataLoadSimulation/Functions/get_random_street.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.get_random_street() RETURNS varchar(50)
```

## Conversion notes
- `ABS(CHECKSUM(NEWID())) % 8999) + 100` → `floor(random() * 8999)::integer + 100`
- `EXEC DataLoadSimulation.GetRandomStreetName @randomStreetName = @var OUTPUT` → `v_street_name := dataloadsimulation.get_random_street_name()`
- `EXEC DataLoadSimulation.GetRandomStreetSuffix @randomStreetSuffix = @var OUTPUT` → `v_street_suffix := dataloadsimulation.get_random_street_suffix()`
- String concatenation: `+` → `||`

## TODOs
None.

## Tables referenced
None (delegates to `get_random_street_name` and `get_random_street_suffix`).
