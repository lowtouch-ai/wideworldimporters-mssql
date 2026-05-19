# Conversion summary: Application.Configuration_DisableInMemory

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_DisableInMemory.sql`
- **Pattern:** DDL management — no-op stub
- **Output:** `postgres/Application/Functions/configuration_disable_in_memory.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION application.configuration_disable_in_memory() RETURNS void
```

## Conversion notes
- `DROP PROCEDURE IF EXISTS Website.InvoiceCustomerOrders`, `InsertCustomerOrders`, `RecordColdRoomTemperatures` → in PG these are managed as regular functions; the drop logic is omitted
- Memory-optimized filegroup and table type drops removed — no PG equivalent
- `SERVERPROPERTY(N'IsXTPSupported')` check removed
- `SERVERPROPERTY(N'EngineEdition')` check removed
- No-op stub
