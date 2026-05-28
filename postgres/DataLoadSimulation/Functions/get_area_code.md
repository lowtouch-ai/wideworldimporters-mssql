# Conversion summary: DataLoadSimulation.GetAreaCode

## Source
- **Function file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Functions/GetAreaCode.sql`
- **Pattern:** Scalar function → `RETURNS varchar(4)`
- **Output:** `postgres/DataLoadSimulation/Functions/get_area_code.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.get_area_code(p_state_province_code varchar(4)) RETURNS varchar(4)
```

## Parameter mapping
| MSSQL Parameter | PG Parameter | Type |
|---|---|---|
| `@StateProvinceCode NVARCHAR(4)` | `p_state_province_code varchar(4)` | `varchar(4)` |

## Conversion notes
- `WITH EXECUTE AS OWNER` → removed
- `SELECT TOP 1 @AreaCode = ac.[AreaCode] FROM ...` → `SELECT ac."AreaCode" INTO _area_code FROM ... LIMIT 1`
- `NVARCHAR(4)` → `varchar(4)`
- `DECLARE @AreaCode AS NVARCHAR(4)` → `_area_code varchar(4)` in DECLARE block

## TODOs
None.

## Tables referenced
| Table | PostgreSQL file |
|---|---|
| `dataloadsimulation.areacode` | `postgres/DataLoadSimulation/Tables/AreaCode.sql` |
