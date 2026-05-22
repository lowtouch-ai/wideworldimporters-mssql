# Conversion summary: DataLoadSimulation.GetRandomStreetSuffix

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomStreetSuffix.sql`
- **Pattern:** Single OUTPUT parameter → RETURNS varchar(20)
- **Output:** `postgres/DataLoadSimulation/Functions/get_random_street_suffix.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.get_random_street_suffix() RETURNS varchar(20)
```

## Conversion notes
- Table variable `@streetSuffix` with 15 VALUES entries → CTE with VALUES
- `SELECT TOP 1 @var = col ... ORDER BY NEWID()` → `SELECT col INTO v_suffix ... ORDER BY random() LIMIT 1`

## TODOs
None.

## Tables referenced
None.
