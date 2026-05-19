# Conversion summary: WebApi.UpdateTransactionTypeFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateTransactionTypeFromJson.sql`
- **Pattern:** Update from JSON
- **Output:** `postgres/WebApi/Functions/update_transaction_type_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.update_transaction_type_from_json(p_transaction_type text, p_transaction_type_id integer, p_user_id integer) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@TransactionType nvarchar(MAX)` | `p_transaction_type text` | text | JSON payload |
| `@TransactionTypeID int` | `p_transaction_type_id integer` | integer | PK filter |
| `@UserID int` | `p_user_id integer` | integer | Audit user |

## Conversion notes
- `OPENJSON … WITH (…)` → `jsonb_to_recordset(p_transaction_type::jsonb) AS json(…)`
- Column names preserved with double-quotes in the UPDATE SET clause

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `application.transactiontypes` | `postgres/Application/Tables/TransactionTypes.sql` |
