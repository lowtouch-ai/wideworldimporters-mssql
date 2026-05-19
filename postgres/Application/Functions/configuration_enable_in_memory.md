# Conversion summary: Application.Configuration_EnableInMemory

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_EnableInMemory.sql`
- **Pattern:** DDL management — no-op stub
- **Output:** `postgres/Application/Functions/configuration_enable_in_memory.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION application.configuration_enable_in_memory() RETURNS void
```

## Conversion notes
- Memory-optimized filegroup creation (`ALTER DATABASE ... ADD FILEGROUP ... CONTAINS MEMORY_OPTIMIZED_DATA`) removed — no PG equivalent
- `MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA` table options removed
- Natively compiled stored procedure creation (`WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER`) removed — all Website SPs converted to regular PL/pgSQL
- Memory-optimized table type recreation removed
- `SERVERPROPERTY(N'IsXTPSupported')` / `SERVERPROPERTY(N'EngineEdition')` checks removed
- No-op stub
