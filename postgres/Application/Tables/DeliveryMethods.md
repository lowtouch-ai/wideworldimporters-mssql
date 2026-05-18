# Conversion summary: DeliveryMethods.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Application/Tables/DeliveryMethods.sql`
- **Output:** `postgres/Application/Tables/DeliveryMethods.sql`

## Conversions applied
- `[Application].[DeliveryMethods]` → `application.delivery_methods`
- `INT` → `INTEGER`
- `NVARCHAR(50)` → `VARCHAR(50)`
- `NEXT VALUE FOR [Sequences].[DeliveryMethodID]` → `nextval('sequences.delivery_method_id_seq')`; sequence emitted
- Named-default constraint `CONSTRAINT [DF_...]` removed
- `GENERATED ALWAYS AS ROW START` / `GENERATED ALWAYS AS ROW END` → `TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP`
- `PERIOD FOR SYSTEM_TIME (...)` removed; `WITH (SYSTEM_VERSIONING = ON ...)` removed
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`; `UNIQUE NONCLUSTERED` → `UNIQUE`
- 1 table-level + 2 column-level extended properties → `COMMENT ON TABLE` / `COMMENT ON COLUMN`

## Next files to convert (unresolved dependencies)

| Dependency | Required by (columns) | Run |
|---|---|---|
| `application.people` | `delivery_methods.LastEditedBy` | `/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/People.sql` |
