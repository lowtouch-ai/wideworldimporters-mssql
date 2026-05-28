# Conversion summary: DataLoadSimulation.GetBogativePhoneNumber

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Functions/GetBogativePhoneNumber.sql`
- **Pattern:** Stored procedure with OUTPUT parameter → scalar `RETURNS varchar(20)`
- **Output:** `postgres/DataLoadSimulation/Functions/get_bogative_phone_number.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.get_bogative_phone_number(p_area_code varchar(4)) RETURNS varchar(20)
```

## Parameter mapping
| MSSQL Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@AreaCode NVARCHAR(4)` | `p_area_code varchar(4)` | `varchar(4)` | Input |
| `@PhoneNumber NVARCHAR(20) OUTPUT` | (return value) | `varchar(20)` | Converted to RETURNS |

## Conversion notes
- Source was a `CREATE PROCEDURE` with an OUTPUT parameter — converted to a scalar function returning the value directly
- `ABS(CHECKSUM(NEWID())) % 9999` → `(floor(random() * 9999))::integer` (equivalent random integer in [0, 9998])
- `RIGHT('0000' + CAST(n AS NVARCHAR), 4)` → `lpad(n::text, 4, '0')`
- String concatenation `+` → `||`
- `NVARCHAR(4)` / `NVARCHAR(20)` → `varchar(4)` / `varchar(20)`

## TODOs
None.

## Tables referenced
None.
