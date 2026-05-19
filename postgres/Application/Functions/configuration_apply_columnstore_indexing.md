# Conversion summary: Application.Configuration_ApplyColumnstoreIndexing

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_ApplyColumnstoreIndexing.sql`
- **Pattern:** DDL management — no-op stub
- **Output:** `postgres/Application/Functions/configuration_apply_columnstore_indexing.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION application.configuration_apply_columnstore_indexing() RETURNS void
```

## Conversion notes
- `NCCX_Sales_OrderLines`, `NCCX_Sales_InvoiceLines`, `CCX_Warehouse_StockItemTransactions` columnstore indexes have no PostgreSQL equivalent
- `SERVERPROPERTY(N'IsXTPSupported')` check removed
- Archive table page compression (`REBUILD PARTITION = ALL WITH DATA_COMPRESSION = PAGE`) removed — PostgreSQL handles storage compression transparently
- No-op stub with NOTICE; consider BRIN indexes or Citus columnar extension for similar workloads

## TODOs
- **No direct PG equivalent**: If analytical query performance is a concern on `sales.orderlines`, `sales.invoicelines`, or `warehouse.stockitemtransactions`, evaluate BRIN indexes or pg_partman with columnar storage.
