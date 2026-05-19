# Conversion summary: Application.Configuration_ApplyAuditing

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_ApplyAuditing.sql`
- **Pattern:** DDL management — no-op stub
- **Output:** `postgres/Application/Functions/configuration_apply_auditing.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION application.configuration_apply_auditing() RETURNS void
```

## Conversion notes
- SQL Server `CREATE SERVER AUDIT`, `CREATE SERVER AUDIT SPECIFICATION`, and `CREATE DATABASE AUDIT SPECIFICATION` have no PostgreSQL equivalent DDL
- PostgreSQL auditing is handled by the `pgaudit` extension configured at the cluster/database level via `postgresql.conf` — cannot be enabled programmatically at runtime through a function
- `sys.server_audits`, `sys.server_audit_specifications`, `sys.database_audit_specifications` system catalog queries removed — no PG equivalents
- Function is a no-op stub that raises NOTICEs explaining the equivalent PG approach
- `SERVERPROPERTY(N'IsXTPSupported')` → removed (SQL Server edition check, not applicable)

## TODOs
- **Manual action required**: Install and configure `pgaudit` extension at the cluster level. See [pgaudit docs](https://github.com/pgaudit/pgaudit).

## Tables referenced
None (SQL Server system catalogs only).
