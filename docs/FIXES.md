# PostgreSQL Migration Fixes

This document describes the DB-side fixes applied after migrating from MSSQL to PostgreSQL
to restore full create and edit functionality across all modules in the wwi-app.

All fixes are **database-only** — no application code was changed.

---

## Fix 1 — Rename webapi views to snake_case

**File:** applied directly via `ALTER VIEW` (no file)

**Problem:** The app references multi-word views using snake_case (e.g. `webapi.customer_transactions`,
`webapi.sales_orders`) but the migration created them without underscores (e.g. `webapi.customertransactions`,
`webapi.salesorders`). This caused a `relation does not exist` error and DataTables Ajax errors on every
table page load.

**Root cause:** MSSQL is case-insensitive so `CustomerTransactions` has no separator convention.
PostgreSQL lowercases all identifiers, and the migration dropped the word boundaries.

**Fix:** Renamed all 17 multi-word views in the `webapi` schema to snake_case:

```sql
ALTER VIEW webapi.customertransactions   RENAME TO customer_transactions;
ALTER VIEW webapi.salesorders            RENAME TO sales_orders;
ALTER VIEW webapi.purchaseorders         RENAME TO purchase_orders;
-- ... (17 views total)
```

---

## Fix 2 — Quote PascalCase aliases in jsonb_to_record / jsonb_to_recordset blocks

**File:** `postgres/fix_jsonb_aliases.sql`

**Problem:** Every edit/save (PUT) operation across all modules returned 500. The error was
`null value in column "X" violates not-null constraint`.

**Root cause:** PostgreSQL silently folds unquoted identifiers to lowercase at parse time.
Inside `jsonb_to_record(...) AS json(TransactionTypeName varchar(50))`, the alias
`TransactionTypeName` became `transactiontypename`. JSONB key lookup is case-sensitive, so
extracting key `"TransactionTypeName"` from the JSON payload returned NULL — which then
violated the NOT NULL constraint on the target column.

MSSQL has no equivalent issue as it is case-insensitive throughout.

**Fix:** Quoted all PascalCase column aliases and their references in all 36 `webapi` functions:

```sql
-- Before (broken):
FROM jsonb_to_record(p_transaction_type::jsonb) AS json(TransactionTypeName varchar(50))
-- After (fixed):
FROM jsonb_to_record(p_transaction_type::jsonb) AS json("TransactionTypeName" varchar(50))
```

Also quoted all `json.ColumnName` / `x.ColumnName` references in SET and SELECT clauses.

**Affects:** 21 `update_*` functions + 15 `insert_*` functions (36 total)

---

## Fix 3 — Wrap single-object JSON in array for insert functions

**File:** `postgres/fix_insert_funcs.sql` *(supersedes fix_jsonb_aliases.sql for insert functions)*

**Problem:** Adding any new record (POST) returned 500: `cannot call jsonb_to_recordset on a non-array`.

**Root cause:** The browser app serialises the form and POSTs a **single JSON object**
e.g. `{"ColorName":"Red"}`. The `jsonb_to_recordset()` function strictly requires a
**JSON array** e.g. `[{"ColorName":"Red"}]`. The original MSSQL stored procedures used
`OPENJSON` which accepts both formats.

**Fix:** Wrapped the input with a runtime type check in all 15 `insert_*` functions:

```sql
FROM jsonb_to_recordset(
    CASE WHEN jsonb_typeof(p_colors::jsonb) = 'array'
         THEN p_colors::jsonb
         ELSE jsonb_build_array(p_colors::jsonb)
    END
) AS x("ColorName" varchar(50))
```

This also incorporates the alias quoting fix from Fix 2, making `fix_insert_funcs.sql`
the authoritative source for all 15 insert functions.

**Affects:** 15 `insert_*` functions

---

## Fix 4 — Reset sequences to MAX(id) of each table

**File:** `postgres/fix_sequences.sql`

**Problem:** After applying Fix 3, adding records still failed with
`duplicate key value violates unique constraint`. Sequence values were stuck at 1
while tables already had thousands of rows from seed data.

**Root cause:** PostgreSQL sequences are independent objects. Unlike MSSQL `IDENTITY` columns
which track the table's current max, PostgreSQL sequences are only advanced when `nextval()`
is called. After the seed data was bulk-loaded (bypassing the sequences), all sequences
remained at their start value of 1.

**Fix:** Reset all 24 sequences to their table's current `MAX(id)`:

```sql
SELECT setval('sequences.color_id_seq',   COALESCE(MAX(colorid),   1)) FROM warehouse.colors;
SELECT setval('sequences.customer_id_seq', COALESCE(MAX(customerid), 1)) FROM sales.customers;
-- ... (24 sequences total)
```

**Affects:** 24 sequences across all schemas

---

## Fix 5 — Search endpoint 500: wrong view name and missing jsonb cast

**Files:** `postgres/WebApi/Functions/search_for_stock_items.sql`, `wwi-app/Controllers/FrontEndController.cs`

**Problem:** `GET /Search?name=...` returned 500 in two scenarios:
1. Any search — `relation "webapi.stockitems" does not exist`
2. Search with `minPrice` set — `function webapi.search_for_stock_items(text, unknown, double precision, ...) does not exist`

**Root cause (1):** `search_for_stock_items` referenced `webapi.stockitems` but the view is named `webapi.stock_items` (snake_case with underscore). PL/pgSQL defers name resolution to execution time, so the function compiled successfully but failed on every call.

**Root cause (2):** Npgsql infers .NET `double` as PostgreSQL `float8/double precision`. The function signature declares `numeric(18,2)`. PostgreSQL function overload resolution is strict and won't implicitly cast `float8` → `numeric`, so no match was found.

**Fix (1):** Corrected the view reference in the function:
```sql
-- Before: FROM webapi.stockitems AS si
FROM webapi.stock_items AS si
```

**Fix (2):** Added `::jsonb` cast where `CustomFields` (stored as `text`) was used with the `->` JSON operator:
```sql
jsonb_array_elements_text(v.CustomFields::jsonb->'Tags')
```

**Fix (3):** Added explicit type casts in the controller SQL so Npgsql parameter types are unambiguous:
```csharp
// Before:
cmd.CommandText = "SELECT webapi.search_for_stock_items($1, $2, $3, $4, $5, $6)";
// After:
cmd.CommandText = "SELECT webapi.search_for_stock_items($1::varchar, $2::varchar, $3::numeric, $4::numeric, $5::int, $6::int)";
```

---

## Execution order

When re-applying to a fresh database, run in this order:

```bash
psql -U postgres < postgres/fix_jsonb_aliases.sql   # Fix update_* functions (21)
psql -U postgres < postgres/fix_insert_funcs.sql    # Fix insert_* functions (15) — also re-fixes aliases
psql -U postgres < postgres/fix_sequences.sql       # Reset all sequences (24)
# View renames must be applied manually or added to the DDL migration
```
