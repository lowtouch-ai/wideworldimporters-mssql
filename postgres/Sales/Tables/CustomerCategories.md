# Conversion summary: CustomerCategories.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sales/Tables/CustomerCategories.sql`
- **Output:** `postgres/Sales/Tables/CustomerCategories.sql`

## Conversions applied
- `[Sales].[CustomerCategories]` → `sales.customer_categories`
- `INT` → `INTEGER`
- `NVARCHAR(50)` → `VARCHAR(50)`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `NEXT VALUE FOR [Sequences].[CustomerCategoryID]` → `nextval('sequences.customer_category_id_seq')` + `CREATE SEQUENCE IF NOT EXISTS sequences.customer_category_id_seq` emitted
- Named-default constraint `CONSTRAINT [DF_Sales_CustomerCategories_CustomerCategoryID] DEFAULT (...)` → `DEFAULT (...)`
- Temporal table: `PERIOD FOR SYSTEM_TIME` clause dropped; `WITH (SYSTEM_VERSIONING = ON ...)` dropped; `GENERATED ALWAYS AS ROW START/END` columns → plain `TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP`
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`
- `UNIQUE NONCLUSTERED` → `UNIQUE`
- 1 table-level extended property → `COMMENT ON TABLE`
- 2 column-level extended properties → `COMMENT ON COLUMN`

All FK dependencies resolved (`application.people` already converted).
