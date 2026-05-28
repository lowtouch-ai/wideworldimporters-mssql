# Conversion summary: PaymentMethods.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Application/Tables/PaymentMethods.sql`
- **Output:** `postgres/Application/Tables/PaymentMethods.sql`

## Conversions applied
- `[Application].[PaymentMethods]` → `application.payment_methods`
- `INT` → `INTEGER`
- `NVARCHAR(50)` → `VARCHAR(50)`
- `NEXT VALUE FOR [Sequences].[PaymentMethodID]` → `nextval('sequences.payment_method_id_seq')`; sequence emitted
- Named-default constraint removed
- `GENERATED ALWAYS AS ROW START` / `GENERATED ALWAYS AS ROW END` → `TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP`
- `PERIOD FOR SYSTEM_TIME (...)` / `WITH (SYSTEM_VERSIONING = ON ...)` removed
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`; `UNIQUE NONCLUSTERED` → `UNIQUE`
- 1 table-level + 2 column-level extended properties → `COMMENT ON TABLE` / `COMMENT ON COLUMN`

## Next files to convert (unresolved dependencies)

| Dependency | Required by (columns) | Run |
|---|---|---|
| `application.people` | `payment_methods.LastEditedBy` | `/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/People.sql` |
