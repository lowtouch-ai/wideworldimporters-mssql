# Conversion summary: Application.Configuration_ApplyRowLevelSecurity

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_ApplyRowLevelSecurity.sql`
- **Pattern:** Simple DML / void utility — DDL management
- **Output:** `postgres/Application/Functions/configuration_apply_row_level_security.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION application.configuration_apply_row_level_security() RETURNS void
```

## Parameter mapping
No parameters.

## Conversion notes
- `DROP SECURITY POLICY IF EXISTS [Application].FilterCustomersBySalesTerritoryRole` → `DROP POLICY IF EXISTS filter_customers_by_territory ON sales.customers` + `DROP POLICY IF EXISTS block_customers_update_by_territory ON sales.customers`
- MSSQL security policy has two predicates; PostgreSQL uses two separate `CREATE POLICY` statements (one FOR SELECT, one FOR UPDATE)
- `FILTER PREDICATE` → `FOR SELECT USING (EXISTS (...))` — row is visible only when `determine_customer_access` returns a non-empty result
- `BLOCK PREDICATE AFTER UPDATE` → `FOR UPDATE WITH CHECK (EXISTS (...))` — update is blocked when predicate returns empty
- `ALTER TABLE sales.customers ENABLE ROW LEVEL SECURITY` added to activate RLS on the table
- The MSSQL SP also inlined a `CREATE FUNCTION DetermineCustomerAccess` DDL block; the PG version relies on the separately converted `application.determine_customer_access` (defined in `postgres/Application/Functions/determine_customer_access.sql`) — no need to redefine it here
- `DeliveryCityID` column is double-quoted in the USING / WITH CHECK clause to preserve casing
- `BEGIN TRY / CATCH / THROW` → `BEGIN / EXCEPTION WHEN OTHERS THEN / RAISE`
- `WITH EXECUTE AS OWNER`, `SET NOCOUNT ON`, `SET XACT_ABORT ON` removed
- Dynamic SQL strings removed — all DDL runs as direct statements within PL/pgSQL

## TODOs
None.

## Tables referenced
| Table | PostgreSQL file |
|---|---|
| `sales.customers` | `postgres/Sales/Tables/Customers.sql` |

## Functions referenced
| Function | PostgreSQL file |
|---|---|
| `application.determine_customer_access` | `postgres/Application/Functions/determine_customer_access.sql` |
