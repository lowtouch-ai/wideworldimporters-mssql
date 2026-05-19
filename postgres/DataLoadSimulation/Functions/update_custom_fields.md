# Conversion summary: DataLoadSimulation.UpdateCustomFields

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/UpdateCustomFields.sql`
- **Pattern:** Complex DML (bulk UPDATEs + cursor with JSON manipulation)
- **Output:** `postgres/DataLoadSimulation/Functions/update_custom_fields.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.update_custom_fields(p_current_date date) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@CurrentDateTime date` | `p_current_date date` | date | Single date parameter |

## Conversion notes
- `JSON_MODIFY(CustomFields, 'append $.Tags', value)` → `jsonb_set("CustomFields"::jsonb, '{Tags}', array || jsonb_build_array(value))::text`
- `sys.syslanguages` → replaced with hardcoded list of 25 world languages
- `DECLARE EmployeeList CURSOR FAST_FORWARD READ_ONLY FOR ... WHILE @@FETCH_STATUS` → `FOR rec IN (...) LOOP`
- `@OtherLanguages TABLE` → `CREATE TEMP TABLE other_languages_tmp (...) ON COMMIT DELETE ROWS`
- `DATEADD(minute, 1, ...)` → `+ interval '1 minute'`
- `DATEADD(hour, 23, ...)` → `+ interval '23 hours'`
- `DATEADD(day, 0 - CEILING(RAND() * 2000) - 100, '20200101')` → `'2020-01-01'::date - (ceil(random()*2000)::integer + 100)`
- `CONVERT(nvarchar(20), date, 126)` → `to_char(date, 'YYYY-MM-DD"T"HH24:MI:SS')`
- `IsChillerStock <> 0` → `<> false`

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `warehouse.stockitems` | `postgres/Warehouse/Tables/StockItems.sql` |
| `warehouse.stockitemstockgroups` | `postgres/Warehouse/Tables/StockItemStockGroups.sql` |
| `warehouse.stockgroups` | `postgres/Warehouse/Tables/StockGroups.sql` |
| `application.people` | `postgres/Application/Tables/People.sql` |
| `application.stateprovinces` | `postgres/Application/Tables/StateProvinces.sql` |
