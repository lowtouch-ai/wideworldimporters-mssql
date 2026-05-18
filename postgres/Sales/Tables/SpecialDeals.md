# Conversion summary: SpecialDeals.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sales/Tables/SpecialDeals.sql`
- **Output:** `postgres/Sales/Tables/SpecialDeals.sql`

## Conversions applied
- `[Sales].[SpecialDeals]` → `sales.specialdeals`
- `INT` → `INTEGER`
- `NVARCHAR(30)` → `VARCHAR(30)`
- `DECIMAL(18,2)` → `NUMERIC(18,2)`, `DECIMAL(18,3)` → `NUMERIC(18,3)`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `NEXT VALUE FOR [Sequences].[SpecialDealID]` → `nextval('sequences.special_deal_id_seq')` + `CREATE SEQUENCE IF NOT EXISTS` emitted
- `DEFAULT (sysdatetime())` → `DEFAULT CURRENT_TIMESTAMP`
- Named-default constraint syntax removed (`CONSTRAINT [DF_...] DEFAULT (...)`)
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`
- CHECK constraints rewritten: MSSQL `CASE` expressions converted to standard SQL (brackets removed, square-bracket column references unquoted)
- 5 × `CREATE NONCLUSTERED INDEX` → `CREATE INDEX`
- 5 index-level extended properties → omitted (with comment)
- 2 constraint-level extended properties → omitted (no PostgreSQL equivalent)
- 1 table-level extended property → `COMMENT ON TABLE`
- 12 column-level extended properties → `COMMENT ON COLUMN`
