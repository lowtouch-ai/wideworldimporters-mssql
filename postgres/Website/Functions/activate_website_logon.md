# activate_website_logon

Converted from: `wwi-ssdt/wwi-ssdt/Website/Stored Procedures/ActivateWebsiteLogon.sql`

## Summary

Enables website logon for a person by setting `IsPermittedToLogon = true`, storing the logon name, and hashing the initial password combined with the person's full name.

## Conversion notes

- `WITH EXECUTE AS OWNER`, `SET NOCOUNT ON`, `SET XACT_ABORT ON` removed
- `@@ROWCOUNT` → `GET DIAGNOSTICS _rowcount = ROW_COUNT`
- `HASHBYTES(N'SHA2_256', ...)` → `encode(digest(..., 'sha256'), 'hex')` — **requires `CREATE EXTENSION IF NOT EXISTS pgcrypto;`**
- `IsPermittedToLogon = 1` → `IsPermittedToLogon = true` (boolean)
- `THROW 51000, ..., 1` → `RAISE EXCEPTION ... USING ERRCODE = 'P0001'`
- `PRINT N'...'` → `RAISE NOTICE '...'`
- `RETURN -1` removed (void function)

## TODOs

- Ensure `pgcrypto` extension is installed: `CREATE EXTENSION IF NOT EXISTS pgcrypto;`
- The hash value stored will differ from MSSQL's `HASHBYTES` — existing password hashes in migrated data are incompatible and will need to be reset.

## Dependencies

| Object | Status |
|---|---|
| `application.people` | check postgres/Application/Tables/People.sql |
