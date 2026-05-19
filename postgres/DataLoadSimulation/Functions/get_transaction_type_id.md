# Conversion summary: DataLoadSimulation.GetTransactionTypeID

## Source
- **Function file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Functions/GetTransactionTypeID.sql`
- **Pattern:** Scalar function → `RETURNS integer`
- **Output:** `postgres/DataLoadSimulation/Functions/get_transaction_type_id.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.get_transaction_type_id(p_transaction_type_name varchar(50)) RETURNS integer
```

## Parameter mapping
| MSSQL Parameter | PG Parameter | Type |
|---|---|---|
| `@TransactionTypeName NVARCHAR(50)` | `p_transaction_type_name varchar(50)` | `varchar(50)` |

## Conversion notes
- `SELECT TOP 1 @TransTypeId = TransactionTypeID FROM Application.TransactionTypes WHERE ... AND ValidTo = '99991231 23:59:59.9999999'` → `SELECT "TransactionTypeID" INTO _trans_type_id FROM application.transactiontypes WHERE ... AND "ValidTo" = '9999-12-31 23:59:59.999999' LIMIT 1`
- `ValidTo = '99991231 23:59:59.9999999'` → `"ValidTo" = '9999-12-31 23:59:59.999999'` (temporal table "current record" sentinel)

## TODOs
None.

## Tables referenced
| Table | PostgreSQL file |
|---|---|
| `application.transactiontypes` | `postgres/Application/Tables/TransactionTypes.sql` |
