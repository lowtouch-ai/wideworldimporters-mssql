# Conversion summary: WebApi.DeleteTransactionType

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteTransactionType.sql`
- **Pattern:** Simple DML (DELETE by primary key)
- **Output:** `postgres/WebApi/Functions/delete_transaction_type.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.delete_transaction_type(p_transaction_type_id integer) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@TransactionTypeID int` | `p_transaction_type_id integer` | integer | PK to delete |

## Conversion notes
- `[WebApi].[DeleteTransactionType]` → `webapi.delete_transaction_type`
- `WITH EXECUTE AS OWNER` removed
- Parameter prefix `@` → `p_`
- Table schema lowercased and mapped to converted postgres table

## TODOs
None.
