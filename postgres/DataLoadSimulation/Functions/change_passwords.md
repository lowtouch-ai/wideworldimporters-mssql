# Conversion summary: DataLoadSimulation.ChangePasswords

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/ChangePasswords.sql`
- **Pattern:** Simple DML (weighted random selection + UPDATE)
- **Output:** `postgres/DataLoadSimulation/Functions/change_passwords.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.change_passwords(p_current_date_time timestamp, p_starting_when timestamp, p_end_of_time timestamp, p_is_silent_mode boolean) RETURNS void
```

## Conversion notes
- `HASHBYTES(N'SHA2_256', ...)` → `digest(..., 'sha256')` from pgcrypto
- VALUES inline table for weighted random selection → CTE with VALUES
- `bit` → `boolean` for `IsPermittedToLogon` comparisons

## TODOs
- Requires: `CREATE EXTENSION IF NOT EXISTS pgcrypto;`

## Tables referenced
| Table | Postgres file |
|---|---|
| `application.people` | `postgres/Application/Tables/People.sql` |
