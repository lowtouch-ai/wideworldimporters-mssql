# Conversion summary: WebApi.InsertCustomersFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertCustomersFromJson.sql`
- **Pattern:** Insert with OUTPUT (batch insert from JSON array, returns inserted IDs)
- **Output:** `postgres/WebApi/Functions/insert_customers_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.insert_customers_from_json(p_customers text, p_user_id integer) RETURNS TABLE(customerid integer)
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@Customers nvarchar(MAX)` | `p_customers text` | text | JSON array payload (26 fields) |
| `@UserID int` | `p_user_id integer` | integer | Audit user |

## Conversion notes
- 26-field OPENJSON WITH → 26-column `jsonb_to_recordset` AS clause with quoted PascalCase keys
- `bit` → `boolean` for IsStatementSent, IsOnCreditHold
- `decimal(18,2/3)` → `numeric(18,2/3)`
- `deliverylocation` (geography) not in original SP — omitted
- `OUTPUT inserted.CustomerID` → `RETURNING customers.customerid`

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.customers` | `postgres/Sales/Tables/Customers.sql` |
