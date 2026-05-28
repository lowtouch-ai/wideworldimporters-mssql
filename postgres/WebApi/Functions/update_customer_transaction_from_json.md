# Conversion summary: WebApi.UpdateCustomerTransactionFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateCustomerTransactionFromJson.sql`
- **Pattern:** Update from JSON (partial update)
- **Output:** `postgres/WebApi/Functions/update_customer_transaction_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.update_customer_transaction_from_json(p_customer_transaction text, p_customer_transaction_id integer, p_user_id integer) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@CustomerTransaction nvarchar(MAX)` | `p_customer_transaction text` | text | JSON object payload |
| `@CustomerTransactionID int` | `p_customer_transaction_id integer` | integer | PK to update |
| `@UserID int` | `p_user_id integer` | integer | Audit user |

## Conversion notes
- `COALESCE` for: TransactionTypeID, TransactionDate, AmountExcludingTax, TaxAmount, TransactionAmount, OutstandingBalance
- Direct assignment for: PaymentMethodID, FinalizationDate (both nullable — can be cleared to NULL)

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.customertransactions` | `postgres/Sales/Tables/CustomerTransactions.sql` |
