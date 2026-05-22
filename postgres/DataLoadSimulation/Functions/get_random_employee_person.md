# Conversion summary: DataLoadSimulation.GetRandomEmployeePerson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomEmployeePerson.sql`
- **Pattern:** Single OUTPUT parameter → RETURNS integer
- **Output:** `postgres/DataLoadSimulation/Functions/get_random_employee_person.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.get_random_employee_person() RETURNS integer
```

## Conversion notes
- `IsEmployee <> 0` → `"IsEmployee" <> false` (bit → boolean)
- `SELECT TOP(1) @var = col ... ORDER BY NEWID()` → `SELECT col INTO v_id ... ORDER BY random() LIMIT 1`

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `application.people` | `postgres/Application/Tables/People.sql` |
