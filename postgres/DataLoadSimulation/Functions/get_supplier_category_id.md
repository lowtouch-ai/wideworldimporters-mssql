# Conversion summary: DataLoadSimulation.GetSupplierCategoryID

## Source
- **Function file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Functions/GetSupplierCategoryID.sql`
- **Pattern:** Scalar function → `RETURNS integer`
- **Output:** `postgres/DataLoadSimulation/Functions/get_supplier_category_id.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.get_supplier_category_id(p_supplier_category_name varchar(50)) RETURNS integer
```

## Parameter mapping
| MSSQL Parameter | PG Parameter | Type |
|---|---|---|
| `@SupplierCategoryName NVARCHAR(50)` | `p_supplier_category_name varchar(50)` | `varchar(50)` |

## Conversion notes
- `SELECT TOP 1 @SupCatID = SupplierCategoryID FROM Purchasing.SupplierCategories WHERE ... AND ValidTo = '99991231 23:59:59.9999999'` → `SELECT "SupplierCategoryID" INTO _sup_cat_id FROM purchasing.suppliercategories WHERE ... AND "ValidTo" = '9999-12-31 23:59:59.999999' LIMIT 1`
- `ValidTo = '99991231 23:59:59.9999999'` → `"ValidTo" = '9999-12-31 23:59:59.999999'` (temporal table "current record" sentinel)

## TODOs
None.

## Tables referenced
| Table | PostgreSQL file |
|---|---|
| `purchasing.suppliercategories` | `postgres/Purchasing/Tables/SupplierCategories.sql` |
