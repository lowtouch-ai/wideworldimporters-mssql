# Conversion summary: WebApi.InsertTransactionTypesFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertTransactionTypesFromJson.sql`
- **Pattern:** Insert with OUTPUT
- **Output:** `postgres/WebApi/Functions/insert_transaction_types_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.insert_transaction_types_from_json(p_transaction_types text, p_user_id integer) RETURNS TABLE(transactiontypeid integer)
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@TransactionTypes nvarchar(MAX)` | `p_transaction_types text` | text | JSON array payload |
| `@UserID int` | `p_user_id integer` | integer | Audit user |

## Conversion notes
- `OPENJSON → jsonb_to_recordset`, `OUTPUT inserted.TransactionTypeID → RETURNING transaction_types.transactiontypeid`

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `application.transaction_types` | `postgres/Application/Tables/TransactionTypes.sql` |
