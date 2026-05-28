# Conversion summary: WebApi.UpdateCustomerFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateCustomerFromJson.sql`
- **Pattern:** Update from JSON (partial update — mixed ISNULL and direct)
- **Output:** `postgres/WebApi/Functions/update_customer_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.update_customer_from_json(p_customer text, p_customer_id integer, p_user_id integer) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@Customer nvarchar(MAX)` | `p_customer text` | text | JSON object payload (26 fields) |
| `@CustomerID int` | `p_customer_id integer` | integer | PK to update |
| `@UserID int` | `p_user_id integer` | integer | Audit user |

## Conversion notes
- `ISNULL(json.Field, Table.Field)` → `COALESCE(x."Field", customers.col)` for fields that preserve existing value
- Direct `x."Field"` for nullable fields that can be cleared: BuyingGroupID, CreditLimit, DeliveryRun, RunPosition, DeliveryAddressLine2, PostalAddressLine2
- `bit` → `boolean` for IsStatementSent, IsOnCreditHold

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.customers` | `postgres/Sales/Tables/Customers.sql` |
