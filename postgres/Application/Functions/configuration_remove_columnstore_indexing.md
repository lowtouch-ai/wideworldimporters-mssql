# Conversion summary: Application.Configuration_RemoveColumnstoreIndexing

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_RemoveColumnstoreIndexing.sql`
- **Pattern:** DDL management — no-op stub
- **Output:** `postgres/Application/Functions/configuration_remove_columnstore_indexing.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION application.configuration_remove_columnstore_indexing() RETURNS void
```

## Conversion notes
- `DROP INDEX` for columnstore indexes removed — no PG equivalent exists
- `SERVERPROPERTY(N'IsXTPSupported')` check removed
- Archive table page compression rebuild removed
- No-op stub
