# pgtable-test report: Sales.InvoiceLines

## Source
- **Table file:** `postgres/Sales/Tables/InvoiceLines.sql`
- **Test run:** 2026-05-18T19:20:22Z

## Dependencies
| Dependency | Status |
|---|---|
| `application.people` | ✓ Applied (pre-existing from Session 1) |
| `sales.invoices` | ✓ Applied (converted this session) |
| `warehouse.packagetypes` | ✓ Applied (pre-existing from Session 2) |
| `warehouse.stockitems` | ✓ Applied (pre-existing from Session 3) |

## Sequences
| Sequence | Status |
|---|---|
| `sequences.invoice_line_id_seq` | ✓ Created (pre-existing from Session 1) |

## Result
- Table load: ✓ Success (FK constraints stripped for test isolation)
- SELECT LIMIT 0: ✓ ok
- Columns verified: 13

## TODOs
- COLUMNSTORE index omitted — no PostgreSQL equivalent.
