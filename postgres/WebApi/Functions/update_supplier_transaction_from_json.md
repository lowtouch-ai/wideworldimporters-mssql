# Conversion summary: WebApi.UpdateSupplierTransactionFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateSupplierTransactionFromJson.sql`
- **Pattern:** Update from JSON
- **Output:** `postgres/WebApi/Functions/update_supplier_transaction_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.update_supplier_transaction_from_json(p_supplier_transaction text, p_supplier_transaction_id integer, p_user_id integer) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@SupplierTransaction nvarchar(MAX)` | `p_supplier_transaction text` | text | JSON payload |
| `@SupplierTransactionID int` | `p_supplier_transaction_id integer` | integer | PK filter |
| `@UserID int` | `p_user_id integer` | integer | Audit user |

## Conversion notes
- `OPENJSON … WITH (…)` → `jsonb_to_recordset(p_supplier_transaction::jsonb) AS json(…)` with 11 field aliases
- `ISNULL(json.X, tbl.X)` → `COALESCE(json.x, tbl."X")` for guarded columns
- `decimal(18,2)` → `numeric(18,2)`; `date` stays `date`
- Nullable-only columns (PurchaseOrderID, PaymentMethodID) set directly

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `purchasing.suppliertransactions` | `postgres/Purchasing/Tables/SupplierTransactions.sql` |
