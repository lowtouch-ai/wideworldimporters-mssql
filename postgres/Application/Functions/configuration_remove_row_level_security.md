# Conversion summary: Application.Configuration_RemoveRowLevelSecurity

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_RemoveRowLevelSecurity.sql`
- **Pattern:** Simple DML / void utility — DDL management
- **Output:** `postgres/Application/Functions/configuration_remove_row_level_security.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION application.configuration_remove_row_level_security() RETURNS void
```

## Parameter mapping
No parameters.

## Conversion notes
- `DROP SECURITY POLICY IF EXISTS [Application].FilterCustomersBySalesTerritoryRole` → two `DROP POLICY IF EXISTS` statements (one per policy created by `configuration_apply_row_level_security`)
- `ALTER TABLE sales.customers DISABLE ROW LEVEL SECURITY` added to deactivate RLS
- `DROP FUNCTION IF EXISTS [Application].DetermineCustomerAccess` — the MSSQL version dropped this function; in PostgreSQL the function is managed separately, so the drop is left as an inline comment with instructions rather than executed automatically
- Dynamic SQL strings removed — all DDL runs as direct statements
- `BEGIN TRY / CATCH / THROW 51000` → `BEGIN / EXCEPTION WHEN OTHERS THEN / RAISE`
- `WITH EXECUTE AS OWNER`, `SET NOCOUNT ON`, `SET XACT_ABORT ON` removed

## TODOs
- **MSSQL drops DetermineCustomerAccess as part of remove**: see inline comment in the function body if manual removal of `application.determine_customer_access` is also needed.

## Tables referenced
| Table | PostgreSQL file |
|---|---|
| `sales.customers` | `postgres/Sales/Tables/Customers.sql` |
