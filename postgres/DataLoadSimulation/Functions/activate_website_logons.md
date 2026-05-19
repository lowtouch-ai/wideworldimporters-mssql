# Conversion summary: DataLoadSimulation.ActivateWebsiteLogons

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/ActivateWebsiteLogons.sql`
- **Pattern:** Simple DML (WHILE loop with UPDATE)
- **Output:** `postgres/DataLoadSimulation/Functions/activate_website_logons.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.activate_website_logons(p_current_date_time timestamp, p_starting_when timestamp, p_end_of_time timestamp, p_is_silent_mode boolean) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@CurrentDateTime datetime2(7)` | `p_current_date_time timestamp` | timestamp | |
| `@StartingWhen datetime` | `p_starting_when timestamp` | timestamp | |
| `@EndOfTime datetime2(7)` | `p_end_of_time timestamp` | timestamp | |
| `@IsSilentMode bit` | `p_is_silent_mode boolean` | boolean | |

## Conversion notes
- `HASHBYTES(N'SHA2_256', ...)` → `digest(..., 'sha256')` from pgcrypto extension
- `ABS(CHECKSUM(NEWID()))` random selection → `ORDER BY random() LIMIT 1`
- `bit` password hashing result stored as `bytea`

## TODOs
- Requires: `CREATE EXTENSION IF NOT EXISTS pgcrypto;`

## Tables referenced
| Table | Postgres file |
|---|---|
| `application.people` | `postgres/Application/Tables/People.sql` |
