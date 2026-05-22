# Conversion summary: Application.Configuration_RemoveAuditing

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_RemoveAuditing.sql`
- **Pattern:** DDL management — no-op stub
- **Output:** `postgres/Application/Functions/configuration_remove_auditing.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION application.configuration_remove_auditing() RETURNS void
```

## Conversion notes
- `DROP DATABASE AUDIT SPECIFICATION`, `DROP SERVER AUDIT SPECIFICATION`, `DROP SERVER AUDIT` → no PostgreSQL equivalents
- `sys.database_audit_specifications`, `sys.server_audit_specifications`, `sys.server_audits` catalog queries removed
- `SERVERPROPERTY(N'IsXTPSupported')` removed
- No-op stub; removal of pgaudit must be done via `postgresql.conf` changes

## TODOs
- **Manual action**: Remove or set to `''` the `shared_preload_libraries = 'pgaudit'` entry in `postgresql.conf`, then restart or reload (`SELECT pg_reload_conf()`).
