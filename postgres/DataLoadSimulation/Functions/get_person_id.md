# Conversion summary: DataLoadSimulation.GetPersonID

## Source
- **Function file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Functions/GetPersonID.sql`
- **Pattern:** Scalar function → `RETURNS integer`
- **Output:** `postgres/DataLoadSimulation/Functions/get_person_id.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.get_person_id(p_full_name varchar(50)) RETURNS integer
```

## Parameter mapping
| MSSQL Parameter | PG Parameter | Type |
|---|---|---|
| `@FullName NVARCHAR(50)` | `p_full_name varchar(50)` | `varchar(50)` |

## Conversion notes
- `SELECT TOP 1 @PerId = PersonID FROM Application.People WHERE FullName = @FullName AND ValidTo = '99991231 23:59:59.9999999'` → `SELECT "PersonID" INTO _per_id FROM application.people WHERE "FullName" = p_full_name AND "ValidTo" = '9999-12-31 23:59:59.999999' LIMIT 1`
- `ValidTo = '99991231 23:59:59.9999999'` → `"ValidTo" = '9999-12-31 23:59:59.999999'` (temporal table "current record" sentinel)

## TODOs
None.

## Tables referenced
| Table | PostgreSQL file |
|---|---|
| `application.people` | `postgres/Application/Tables/People.sql` |
