# pgtable-test report: Purchasing.SupplierTransactions

## Source
- **Table file:** `postgres/Purchasing/Tables/SupplierTransactions.sql`
- **Test run:** 2026-05-18T19:20:22Z

## Dependencies
| Dependency | Status |
|---|---|
| `application.people` | ✓ Applied (pre-existing from Session 1) |
| `application.paymentmethods` | ✓ Applied (pre-existing from Session 1) |
| `application.transactiontypes` | ✓ Applied (pre-existing from Session 1) |
| `purchasing.purchaseorders` | ✓ Applied (pre-existing from Session 3) |
| `purchasing.suppliers` | ✓ Applied (pre-existing from Session 2) |

## Sequences
| Sequence | Status |
|---|---|
| `sequences.transaction_id_seq` | ✓ Created (pre-existing from Session 1) |

## Result
- Table load: ✓ Success (FK constraints stripped for test isolation)
- SELECT LIMIT 0: ✓ ok
- Columns verified: 15

## TODOs
- Partition scheme PS_TransactionDate omitted from all 6 indexes — no PostgreSQL equivalent.
- `IsFinalized` is a GENERATED ALWAYS AS STORED boolean column (was PERSISTED computed in MSSQL).
