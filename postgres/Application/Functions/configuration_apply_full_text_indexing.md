# Conversion summary: Application.Configuration_ApplyFullTextIndexing

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_ApplyFullTextIndexing.sql`
- **Pattern:** DDL management — partial conversion (GIN indexes created)
- **Output:** `postgres/Application/Functions/configuration_apply_full_text_indexing.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION application.configuration_apply_full_text_indexing() RETURNS void
```

## Conversion notes
- `CREATE FULLTEXT CATALOG FTCatalog` → removed (no equivalent; PG uses GIN indexes directly on columns)
- `sys.fulltext_catalogs` / `sys.fulltext_indexes` catalog checks → removed; replaced by `CREATE INDEX IF NOT EXISTS` (idempotent)
- `SERVERPROPERTY(N'IsFullTextInstalled')` check removed
- `CREATE FULLTEXT INDEX ON ... KEY INDEX PK_ WITH CHANGE_TRACKING AUTO` → `CREATE INDEX IF NOT EXISTS ... USING GIN (to_tsvector('english', ...))`
- Multi-column MSSQL fulltext indexes (People, StockItems) → single combined GIN index with concatenated tsvector expressions
- `CustomFields`, `OtherLanguages`, `Tags` cast to `::text` to handle possible `jsonb` column type
- **Search SPs not recreated here**: The MSSQL version also inlined DROP/CREATE for `Website.SearchForPeople`, `Website.SearchForSuppliers`, `Website.SearchForCustomers`, `Website.SearchForStockItems`, `Website.SearchForStockItemsByTags`. All five have their own converted PL/pgSQL functions in `postgres/Website/Functions/`; use those instead
- `FREETEXTTABLE` in search SPs → converted separately using `to_tsvector`/`to_tsquery` in the Website function conversions

## TODOs
- **Verify column types**: `CustomFields`, `OtherLanguages`, `Tags` — if `text` columns remove the `::text` cast; if `jsonb`, the cast is required
- **Search functions use tsquery**: The converted Website search functions (`search_for_people`, etc.) use `to_tsvector @@ to_tsquery(...)` rather than `FREETEXTTABLE`. Verify query shapes match the expected search behaviour

## Tables referenced
| Table | PostgreSQL file |
|---|---|
| `application.people` | `postgres/Application/Tables/People.sql` |
| `sales.customers` | `postgres/Sales/Tables/Customers.sql` |
| `purchasing.suppliers` | `postgres/Purchasing/Tables/Suppliers.sql` |
| `warehouse.stockitems` | `postgres/Warehouse/Tables/StockItems.sql` |
