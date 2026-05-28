# Conversion summary: DataLoadSimulation.GetRandomSecondaryAddress

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomSecondaryAddress.sql`
- **Pattern:** Single OUTPUT parameter → RETURNS varchar(20)
- **Output:** `postgres/DataLoadSimulation/Functions/get_random_secondary_address.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.get_random_secondary_address() RETURNS varchar(20)
```

## Conversion notes
- Table variable `@seconaryAddress` with VALUES → CTE with VALUES
- `ABS(CHECKSUM(NEWID())) % 899` → `floor(random() * 899)::integer`
- Many blank entries in VALUES preserved to maintain weighted probability of blank result
- `LEN(@sa) > 0` → `LENGTH(v_sa) > 0`

## TODOs
None.

## Tables referenced
None.
