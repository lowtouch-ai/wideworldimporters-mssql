# Conversion summary: WebApi.UpdateSupplierFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateSupplierFromJson.sql`
- **Pattern:** Update from JSON
- **Output:** `postgres/WebApi/Functions/update_supplier_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.update_supplier_from_json(p_supplier text, p_supplier_id integer, p_user_id integer) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@Supplier nvarchar(MAX)` | `p_supplier text` | text | JSON payload |
| `@SupplierID int` | `p_supplier_id integer` | integer | PK filter |
| `@UserID int` | `p_user_id integer` | integer | Audit user |

## Conversion notes
- `OPENJSON … WITH (…)` → `jsonb_to_recordset(p_supplier::jsonb) AS json(…)` with 24 field aliases (snake_case)
- `ISNULL(json.X, tbl.X)` → `COALESCE(json.x, tbl."X")` for all nullable-guarded columns
- Columns set directly (no ISNULL): DeliveryMethodID, SupplierReference, BankInternationalCode

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `purchasing.suppliers` | `postgres/Purchasing/Tables/Suppliers.sql` |
