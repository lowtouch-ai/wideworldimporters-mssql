# Conversion summary: Integration.GetEmployeeUpdates

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetEmployeeUpdates.sql`
- **Pattern:** Complex / cursor / temporal
- **Output:** `postgres/Integration/Functions/get_employee_updates.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION integration.get_employee_updates(
    p_last_cutoff timestamp,
    p_new_cutoff  timestamp
) RETURNS TABLE(
    "WWI Employee ID" integer,
    "Employee" varchar(50),
    "Preferred Name" varchar(50),
    "Is Salesperson" boolean,
    "Photo" bytea,
    "Valid From" timestamp,
    "Valid To" timestamp
)
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@LastCutoff datetime2(7)` | `p_last_cutoff timestamp` | timestamp | Lower bound (exclusive) |
| `@NewCutoff datetime2(7)` | `p_new_cutoff timestamp` | timestamp | Upper bound (inclusive) |

## Conversion notes
- Same cursor + temp table + temporal + UPDATE + SELECT pattern as `GetPaymentMethodUpdates` and `GetTransactionTypeUpdates`
- `AND p.IsEmployee <> 0` → `AND p.IsEmployee = true` (bit → boolean)
- `Photo varbinary(max)` → `bytea` in both temp table and RETURNS TABLE
- `[Is Salesperson] bit` → `boolean`
- `DECLARE @EndOfTime datetime2(7) = '9999...'` → `_end_of_time timestamp := '9999-12-31 23:59:59.9999999'`
- `CREATE TABLE #EmployeeChanges` → `DROP TABLE IF EXISTS employeechanges; CREATE TEMP TABLE employeechanges (...)`
- `DECLARE EmployeeChangeList CURSOR FAST_FORWARD … WHILE @@FETCH_STATUS = 0` → `FOR rec IN (UNION ALL query) LOOP`
- `INSERT #EmployeeChanges` → `INSERT INTO employeechanges`
- `CREATE INDEX IX_EmployeeChanges` → `CREATE INDEX ix_employeechanges`
- `UPDATE cc SET … FROM #EmployeeChanges AS cc` → `UPDATE employeechanges AS cc SET …`
- Final SELECT → `RETURN QUERY SELECT … FROM employeechanges`
- `DROP TABLE #EmployeeChanges` → `DROP TABLE IF EXISTS employeechanges`

## TODOs
- **FOR SYSTEM_TIME AS OF rec.validfrom** — Not supported natively in PostgreSQL. Approximation uses archive table with `ValidFrom <= ts AND ValidTo > ts` UNION current-table fallback, taking the most recent match (ORDER BY ValidFrom DESC LIMIT 1).

## Tables referenced
| Table | Postgres file |
|---|---|
| `application.people_archive` | `postgres/Application/Tables/People_Archive.sql` |
| `application.people` | `postgres/Application/Tables/People.sql` |
