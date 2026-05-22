# Conversion summary: DataLoadSimulation.GetFicticiousName

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetFicticiousName.sql`
- **Pattern:** Multi-value OUTPUT parameters → RETURNS TABLE(first_name, last_name, full_name, email)
- **Output:** `postgres/DataLoadSimulation/Functions/get_ficticious_name.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.get_ficticious_name()
RETURNS TABLE(first_name varchar(20), last_name varchar(20), full_name varchar(40), email varchar(200))
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@FirstName NVARCHAR(20) OUTPUT` | `first_name` | varchar(20) | TABLE column |
| `@LastName NVARCHAR(20) OUTPUT` | `last_name` | varchar(20) | TABLE column |
| `@FullName NVARCHAR(40) OUTPUT` | `full_name` | varchar(40) | TABLE column |
| `@Email NVARCHAR(200) OUTPUT` | `email` | varchar(200) | TABLE column |

## Conversion notes
- `SELECT TOP 1 @var = col ... ORDER BY NEWID()` → `RETURN QUERY SELECT ... ORDER BY random() LIMIT 1`
- Subquery exclusion of already-used names preserved as-is

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `dataloadsimulation.ficticiousnamepool` | `postgres/DataLoadSimulation/Tables/FicticiousNamePool.sql` |
| `application.people` | `postgres/Application/Tables/People.sql` |
