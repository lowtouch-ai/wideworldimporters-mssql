# Conversion summary: Integration.GetStockItemUpdates

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetStockItemUpdates.sql`
- **Pattern:** Complex / cursor / temporal
- **Output:** `postgres/Integration/Functions/get_stock_item_updates.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION integration.get_stock_item_updates(
    p_last_cutoff timestamp,
    p_new_cutoff  timestamp
) RETURNS TABLE(17 columns: "WWI Stock Item ID" integer .. "Valid To" timestamp)
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@LastCutoff datetime2(7)` | `p_last_cutoff timestamp` | timestamp | Lower bound (exclusive) |
| `@NewCutoff datetime2(7)` | `p_new_cutoff timestamp` | timestamp | Upper bound (inclusive) |

## Conversion notes
- Same cursor + temp table + temporal + UPDATE + SELECT base pattern as other Integration SPs
- **4 temporal JOINs** inside the loop body: StockItems, PackageTypes (unit), PackageTypes (outer), Colors — all `FOR SYSTEM_TIME AS OF @ValidFrom`
- `Photo varbinary(max)` → `bytea` in temp table and RETURNS TABLE
- `[Is Chiller Stock] bit` → `boolean`
- `decimal(18,2)` / `decimal(18,3)` → `numeric(18,2)` / `numeric(18,3)`
- `ISNULL(Color, N'N/A')` / `ISNULL(Brand, N'N/A')` / `ISNULL(Size, N'N/A')` / `ISNULL(Barcode, N'N/A')` → `COALESCE(col, 'N/A')` in final RETURN QUERY
- `DROP TABLE IF EXISTS stockitemchanges; CREATE TEMP TABLE stockitemchanges (...)` for idempotency
- `DECLARE StockItemChangeList CURSOR FAST_FORWARD … WHILE @@FETCH_STATUS = 0` → `FOR rec IN (UNION ALL query) LOOP`
- `CREATE INDEX IX_StockItemChanges` → `CREATE INDEX ix_stockitemchanges`
- `UPDATE cc SET … FROM #StockItemChanges AS cc` → `UPDATE stockitemchanges AS cc SET …`
- Final SELECT with ISNULL → `RETURN QUERY SELECT … COALESCE …`
- `DROP TABLE #StockItemChanges` → `DROP TABLE IF EXISTS stockitemchanges`

## TODOs
- **FOR SYSTEM_TIME AS OF rec.validfrom (4 tables)** — Not natively supported in PostgreSQL. Each temporal table converted to `(archive WHERE ValidFrom <= ts AND ValidTo > ts) UNION ALL (current WHERE ValidFrom <= ts)`. `DISTINCT ON (PK) ORDER BY PK, ValidFrom DESC` used for PackageTypes and Colors snapshots to ensure one row per key. StockItems snapshot uses `LIMIT 1 ORDER BY ValidFrom DESC`. Verify row deduplication is correct for all temporal edge cases.

## Tables referenced
| Table | Postgres file |
|---|---|
| `warehouse.stockitems_archive` | `postgres/Warehouse/Tables/StockItems_Archive.sql` |
| `warehouse.stockitems` | `postgres/Warehouse/Tables/StockItems.sql` |
| `warehouse.packagetypes_archive` | `postgres/Warehouse/Tables/PackageTypes_Archive.sql` |
| `warehouse.packagetypes` | `postgres/Warehouse/Tables/PackageTypes.sql` |
| `warehouse.colors_archive` | `postgres/Warehouse/Tables/Colors_Archive.sql` |
| `warehouse.colors` | `postgres/Warehouse/Tables/Colors.sql` |
