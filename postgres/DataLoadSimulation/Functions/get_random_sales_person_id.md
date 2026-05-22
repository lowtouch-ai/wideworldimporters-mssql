# Conversion summary: DataLoadSimulation.GetRandomSalesPersonID

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomSalesPersonID.sql`
- **Pattern:** Single OUTPUT parameter → RETURNS integer
- **Output:** `postgres/DataLoadSimulation/Functions/get_random_sales_person_id.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.get_random_sales_person_id() RETURNS integer
```

## Conversion notes
- `IsSalesperson <> 0` → `"IsSalesperson" <> false` (bit → boolean)
- `SELECT TOP 1 @var = col ... ORDER BY NEWID()` → `SELECT col INTO v_id ... ORDER BY random() LIMIT 1`

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `application.people` | `postgres/Application/Tables/People.sql` |
