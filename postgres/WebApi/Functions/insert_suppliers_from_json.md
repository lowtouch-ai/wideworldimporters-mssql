# Conversion summary: WebApi.InsertSuppliersFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertSuppliersFromJson.sql`
- **Pattern:** Insert with OUTPUT (batch insert from JSON array, returns inserted IDs)
- **Output:** `postgres/WebApi/Functions/insert_suppliers_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.insert_suppliers_from_json(p_suppliers text, p_user_id integer) RETURNS TABLE(supplierid integer)
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@Suppliers nvarchar(MAX)` | `p_suppliers text` | text | JSON array payload (25 fields) |
| `@UserID int` | `p_user_id integer` | integer | Audit user |

## Conversion notes
- 25-field OPENJSON WITH → 25-column `jsonb_to_recordset` AS clause
- `deliverylocation` (geography) not in original SP — omitted
- `OUTPUT inserted.SupplierID → RETURNING suppliers.supplierid`

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `purchasing.suppliers` | `postgres/Purchasing/Tables/Suppliers.sql` |
