# Conversion summary: Application.Configuration_PrepareForAzureStandard

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_PrepareForAzureStandard.sql`
- **Pattern:** Orchestrator — calls two sub-procedures
- **Output:** `postgres/Application/Functions/configuration_prepare_for_azure_standard.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION application.configuration_prepare_for_azure_standard() RETURNS void
```

## Conversion notes
- `EXEC [Application].[Configuration_RemoveColumnstoreIndexing]` → `PERFORM application.configuration_remove_columnstore_indexing()` (no-op stub)
- `EXEC [Application].[Configuration_DisableInMemory]` → `PERFORM application.configuration_disable_in_memory()` (no-op stub)
- `RETURN 0` removed (void function)

## Functions called
| Function | PostgreSQL file |
|---|---|
| `application.configuration_remove_columnstore_indexing` | `postgres/Application/Functions/configuration_remove_columnstore_indexing.sql` |
| `application.configuration_disable_in_memory` | `postgres/Application/Functions/configuration_disable_in_memory.sql` |
