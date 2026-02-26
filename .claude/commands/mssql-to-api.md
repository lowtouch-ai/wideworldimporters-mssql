---
description: Convert a MSSQL stored procedure to a FastAPI endpoint with SQLAlchemy async, generating scaffold if needed.
argument-hint: <stored-procedure-sql-file>
allowed-tools: [Read, Glob, Grep, Write, Edit]
---

# MSSQL → FastAPI Endpoint Conversion

Given `$ARGUMENTS` (a single `.sql` file):

## Step 1 — Validate input

- Confirm `$ARGUMENTS` is a single `.sql` file under `wwi-ssdt/wwi-ssdt/<Schema>/Stored Procedures/`.
- If not, print an error and stop:
  ```
  Error: expected a stored procedure .sql file under wwi-ssdt/wwi-ssdt/<Schema>/Stored Procedures/
  ```
- Extract `<Schema>` (e.g. `WebApi`) and `<SPName>` (e.g. `DeleteBuyingGroup`) from the path.

## Step 2 — Read and parse the SP

- Read the `.sql` file.
- Extract:
  - Procedure name and schema (`[WebApi].[DeleteBuyingGroup]`)
  - All parameters: name, data type, direction (`OUTPUT`), TVP type name if any (e.g. `[Website].[OrderLineList] READONLY`)
  - All referenced tables, views, functions, sequences, and UDTs by scanning for `[Schema].[Object]` or `Schema.Object` patterns in `FROM`, `JOIN`, `INSERT INTO`, `UPDATE`, `DELETE`, `NEXT VALUE FOR`, and `EXEC` clauses
  - Ignore self-references to the procedure's own schema+name

## Step 3 — Dependency check (gate)

For each referenced **table**:
1. Compute expected postgres path: `postgres/<Schema>/Tables/<Table>.sql`
2. Check existence via Glob

**If any table dependencies are missing → STOP.** Print exactly this format:

```
Cannot generate API endpoint — these PostgreSQL table conversions are missing:

  Missing: postgres/Sales/Tables/BuyingGroups.sql
    → Run: /mssql-to-postgres wwi-ssdt/wwi-ssdt/Sales/Tables/BuyingGroups.sql

  Missing: postgres/Application/Tables/People.sql
    → Run: /mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/People.sql

Convert tables first, then re-run:
  /mssql-to-api <original-argument>
```

For missing **views** or **functions**: print a warning but continue (do not gate on them):
```
Warning: referenced view/function not yet converted:
  postgres/Website/Views/Customers.sql
```

## Step 4 — Classify SP pattern

Determine which template to apply based on the SP signature and body:

| Pattern | Detection heuristic | HTTP Method | Response |
|---|---|---|---|
| Simple DELETE | `DELETE ... WHERE PK = @Param`, single table | DELETE | 204 No Content / 404 |
| Insert from JSON | `OPENJSON` + `INSERT` + `OUTPUT inserted` | POST | 201, return inserted IDs |
| Update from JSON | `OPENJSON` + `UPDATE` + `ISNULL` pattern | PUT | 200 / 404 |
| Search / Query | `SELECT ... FOR JSON` or returns a result set | GET | 200, return list |
| Transaction with TVPs | TVP parameters + `BEGIN TRAN` | POST | 201 / 400 |
| Auth / Password | `HASHBYTES` or password-related parameters | POST | 200 / 401 |
| Bulk sensor data | `OPENJSON` on array + INSERT loop | POST | 201 |
| Admin / DDL | Dynamic SQL / `EXECUTE(@SQL)` | — | **Skip with warning** |

If the pattern is Admin/DDL, print:
```
Skipping: this SP uses dynamic SQL and is not suitable for direct API conversion.
```
and stop.

## Step 5 — Ensure scaffold exists

Check for the existence of each file below. **Only create files that do not already exist.** Do not overwrite existing scaffold files.

### `api/requirements.txt`
```
fastapi>=0.115.0
uvicorn[standard]>=0.32.0
sqlalchemy[asyncio]>=2.0.36
asyncpg>=0.30.0
pydantic>=2.10.0
pydantic-settings>=2.7.0
```

### `api/db.py`
```python
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    database_url: str = "postgresql+asyncpg://localhost:5432/wideworldimporters"

    model_config = {"env_prefix": "WWI_"}


settings = Settings()

engine = create_async_engine(settings.database_url, echo=False)
async_session = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)


async def get_session() -> AsyncSession:
    async with async_session() as session:
        yield session
```

### `api/main.py`
```python
from fastapi import FastAPI

app = FastAPI(title="WideWorldImporters API")
```

### `api/schemas/__init__.py`
Empty file.

## Step 6 — Ensure schema router package exists

Compute `<schema_lower>` = lowercase schema name (e.g. `webapi`).
Compute `<schema_kebab>` = kebab-case schema name (e.g. `web-api` for `WebApi`, `application` for `Application`). Use kebab-case by inserting hyphens before uppercase letters and lowercasing.

If `api/routers/<schema_lower>/__init__.py` does **not** exist, create it:

```python
from fastapi import APIRouter

router = APIRouter(prefix="/<schema_kebab>", tags=["<Schema>"])
```

(Replace `<schema_kebab>` and `<Schema>` with actual values.)

Then read `api/main.py` and **append** the router registration if the import line is not already present:

```python
from api.routers.<schema_lower> import router as <schema_lower>_router
app.include_router(<schema_lower>_router)
```

## Step 7 — Generate Pydantic models

Inspect the SP body for input data structures:

### OPENJSON ... WITH (...) clauses
Parse the column definitions inside `WITH (...)`. For each column:
- If the JSON path contains `N'strict $.FieldName'` → **required** field
- If no `strict` keyword → `Optional` field with `None` default
- Map MSSQL types to Python types using this table:

| MSSQL type | Python type |
|---|---|
| `int` | `int` |
| `bigint` | `int` |
| `nvarchar(n)` / `nvarchar(max)` | `str` |
| `decimal(p,s)` / `numeric(p,s)` | `Decimal` |
| `date` | `date` |
| `datetime2` | `datetime` |
| `bit` | `bool` |

### TVP parameters
If the SP accepts a TVP parameter (e.g. `@OrderLines [Website].[OrderLineList] READONLY`):
- Read the UDT definition from `wwi-ssdt/wwi-ssdt/<Schema>/User Defined Types/<TypeName>.sql`
- Parse columns → Pydantic model fields (all required unless nullable)

### Output location
Write or append models to `api/schemas/<schema_lower>.py`. If the file exists, read it first and only append new models (do not duplicate classes that already exist by name).

Model naming: `<SPNameWithoutVerb>Request` for input, `<SPNameWithoutVerb>Response` for output.
Example: `InsertCustomer` → `CustomerRequest`, `CustomerResponse`.

If the SP has no JSON input or TVP parameters (e.g. simple DELETE by ID), skip model generation for that SP.

## Step 8 — Generate endpoint file

Write `api/routers/<schema_lower>/<sp_snake_name>.py`

### Naming conventions

| Source | Target |
|---|---|
| SP `[WebApi].[DeleteBuyingGroup]` | File: `delete_buying_group.py` |
| Function name | `delete_buying_group` |
| PascalCase | snake_case |
| Strip `FromJson` suffix from function name | `insert_customer` not `insert_customer_from_json` |

### HTTP method from SP verb

| Verb prefix | HTTP method |
|---|---|
| `Delete` | DELETE |
| `Insert`, `Record` | POST |
| `Update`, `Edit` | PUT |
| `Search`, `Get`, `Fetch` | GET |
| Other | POST |

### URL path

- Entity operations with ID parameter: `/<resource-kebab-case>/{id}`
  - Example: `DeleteBuyingGroup` with `@BuyingGroupID` → DELETE `"/buying-groups/{buying_group_id}"`
- Search endpoints: `/<resource-kebab-case>/search`
  - Example: `SearchForCustomers` → GET `"/customers/search"`
- Insert/create endpoints: `/<resource-kebab-case>`
  - Example: `InsertCustomerOrders` → POST `"/customer-orders"`

### Endpoint file structure

```python
"""<Schema>.<SPName> → <HTTP_METHOD> <url_path>"""

import hashlib  # only if HASHBYTES used
from datetime import date, datetime  # as needed
from decimal import Decimal  # as needed

from fastapi import Depends, HTTPException, Query  # as needed
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from api.db import get_session
from api.routers.<schema_lower> import router
# from api.schemas.<schema_lower> import SomeRequest  # if models generated


@router.<method>("<url_path>", status_code=<code>)
async def <function_name>(
    <path_params>,
    <query_params>,
    <body: RequestModel>,  # if applicable
    session: AsyncSession = Depends(get_session),
) -> <return_type>:
    async with session.begin():
        <translated_logic>
```

### Key SQL/Python conversion rules

Apply these mappings when translating the SP body:

| MSSQL construct | Python / SQLAlchemy equivalent |
|---|---|
| `DELETE FROM [S].[T] WHERE PK = @P` | `await session.execute(text("DELETE FROM s.t WHERE \"PK\" = :p"), {"p": p})` |
| `INSERT INTO [S].[T] (...) OUTPUT inserted.PK` | `result = await session.execute(text("INSERT INTO s.t (...) VALUES (...) RETURNING \"PK\""), {...})` |
| `UPDATE [S].[T] SET ... WHERE PK = @P` | `await session.execute(text("UPDATE s.t SET ... WHERE \"PK\" = :p"), {...})` |
| `OPENJSON(@json) WITH (...)` | Parse via Pydantic model (the JSON is the request body) |
| `SELECT ... FOR JSON AUTO, ROOT(N'Key')` | Execute query, `rows = result.mappings().all()`, return `{"Key": [dict(r) for r in rows]}` |
| `SELECT TOP(@n)` | Add `LIMIT :n` to the SQL text |
| `WHERE col LIKE '%' + @term + '%'` | `WHERE "col" ILIKE :term` with param `f"%{term}%"` |
| `NEXT VALUE FOR [Sequences].[X]` | `text("SELECT nextval('sequences.x_seq')")` |
| `@@ROWCOUNT = 0` → error | `if result.rowcount == 0: raise HTTPException(status_code=404, detail="Not found")` |
| `HASHBYTES(N'SHA2_256', @input)` | `hashlib.sha256(input.encode()).digest()` |
| `BEGIN TRY ... BEGIN TRAN ... COMMIT TRAN ... END TRY ... BEGIN CATCH` | `async with session.begin():` (transaction block; errors raise exceptions naturally) |
| `THROW 51000, N'message', 1` | `raise HTTPException(status_code=400, detail="message")` |
| `ISNULL(json.col, existing.col)` (conditional update) | Build update dict via `model.model_dump(exclude_unset=True)`, only SET provided fields |
| `SET NOCOUNT ON` | Omit |
| `SET XACT_ABORT ON` | Omit |
| `EXECUTE AS OWNER` | Omit |
| `@UserID int` (audit/context parameter) | Query parameter with comment: `# TODO: replace with auth dependency` |

### SQL text style

- Use `text()` with named `:param` placeholders — do **not** use f-strings for SQL values.
- Schema and table names: **lowercase** (`sales.orders`).
- Column names: **preserve original casing**, always double-quoted in SQL text (`"OrderID"`, `"CustomerPurchaseOrderNumber"`).
- Reference the postgres table/column names (matching the converted postgres DDL output).

## Step 9 — Register endpoint in router

Read `api/routers/<schema_lower>/__init__.py`. If it does not already import the new endpoint module, add the import at the end of the file:

```python
from api.routers.<schema_lower> import <sp_snake_name>  # noqa: F401
```

This ensures the `@router` decorators in the endpoint file are executed when the router package is loaded.

## Step 10 — Write companion markdown

Write `api/routers/<schema_lower>/<sp_snake_name>.md`:

```markdown
# Conversion summary: <Schema>.<SPName>

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/<Schema>/Stored Procedures/<SPName>.sql`
- **Pattern:** <classified pattern from Step 4>
- **HTTP:** <METHOD> `<url_path>` → <status codes>

## Tables/views referenced
| Object | Postgres file | Status |
|---|---|---|
| `[Sales].[BuyingGroups]` | `postgres/Sales/Tables/BuyingGroups.sql` | Converted |
| `[Website].[Customers]` | `postgres/Website/Views/Customers.sql` | Warning: not converted |

## Parameter mapping
| SP Parameter | Endpoint parameter | Type | Notes |
|---|---|---|---|
| `@BuyingGroupID int` | Path param `buying_group_id: int` | int | Primary key |
| `@UserID int` | Query param `user_id: int` | int | TODO: replace with auth |

## SQL construct conversions
- `DELETE ... WHERE` → `text("DELETE ... WHERE")` with `:param`
- `@@ROWCOUNT = 0` → `result.rowcount == 0` → `HTTPException(404)`
- (list each conversion actually applied)

## Warnings / manual review items
- (any items that need human review, e.g. complex business logic, auth concerns)
```

Only include sections and rows relevant to the SP being converted. Omit empty sections.

## Step 11 — Print inline summary

Print the conversion summary directly to the conversation (do not make the user open the `.md` file to see results).

Include:
- Source SP and classified pattern
- HTTP method and URL path
- Files created/modified
- Any warnings or manual review items

Then check for other unconverted SPs in the same schema folder. If there are more, list them as suggestions:

```
Other stored procedures in <Schema> not yet converted:

  /mssql-to-api wwi-ssdt/wwi-ssdt/<Schema>/Stored Procedures/InsertCustomer.sql
  /mssql-to-api wwi-ssdt/wwi-ssdt/<Schema>/Stored Procedures/UpdateCustomer.sql
  ...
```

## Important notes

- **Never auto-commit generated files.** Leave all output files uncommitted for user review.
- All SQL in generated Python must use parameterized queries via `text()` — never interpolate values with f-strings.
- The generated code should be functional but may need manual adjustments for complex business logic. Flag these with `# TODO:` comments.
- When multiple SPs share the same Pydantic model structure, reuse the existing model rather than creating a duplicate.
