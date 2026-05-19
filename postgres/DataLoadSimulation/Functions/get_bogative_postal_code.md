# Conversion summary: DataLoadSimulation.GetBogativePostalCode

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetBogativePostalCode.sql`
- **Pattern:** Scalar return (OUTPUT parameter → RETURNS varchar(10))
- **Output:** `postgres/DataLoadSimulation/Functions/get_bogative_postal_code.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.get_bogative_postal_code(p_city_id integer) RETURNS varchar(10)
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@CityID INT` | `p_city_id integer` | integer | |
| `@PostalCode NVARCHAR(10) OUTPUT` | return value | varchar(10) | OUTPUT param → function return |

## Conversion notes
- OUTPUT parameter converted to scalar RETURNS varchar(10)
- `ABS(CHECKSUM(NEWID())) % 99999` → `floor(random() * 99999)::integer` (equivalent random integer 0–99998)
- `RIGHT('00000' + CAST(n AS NVARCHAR), 5)` → `LPAD(CAST(n AS varchar), 5, '0')`
- `SELECT TOP 1 @var = col FROM` → `SELECT col INTO var FROM ... LIMIT 1`
- `ValidTo = '9999-12-31 23:59:59.9999999'` → `'9999-12-31 23:59:59.999999'` (timestamp(6) precision)

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `application.cities` | `postgres/Application/Tables/Cities.sql` |
| `application.stateprovinces` | `postgres/Application/Tables/StateProvinces.sql` |
| `application.countries` | `postgres/Application/Tables/Countries.sql` |
