# Conversion summary: DataLoadSimulation.GetRandomStreetName

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomStreetName.sql`
- **Pattern:** Single OUTPUT parameter → RETURNS varchar(20)
- **Output:** `postgres/DataLoadSimulation/Functions/get_random_street_name.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.get_random_street_name() RETURNS varchar(20)
```

## Conversion notes
- Table variable `@streetName` with 60 VALUES entries → CTE with VALUES
- `SELECT TOP 1 @var = col ... ORDER BY NEWID()` → `SELECT col INTO v_name ... ORDER BY random() LIMIT 1`

## TODOs
None.

## Tables referenced
None.
