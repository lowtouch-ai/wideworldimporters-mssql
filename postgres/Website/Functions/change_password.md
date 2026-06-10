# change_password

Converted from: `wwi-ssdt/wwi-ssdt/Website/Stored Procedures/ChangePassword.sql`

## Summary

Changes a person's password by verifying the old password hash matches before updating to the new hash.

## Conversion notes

- `WITH EXECUTE AS OWNER`, `SET NOCOUNT ON`, `SET XACT_ABORT ON` removed
- `HASHBYTES('SHA2_256', ...)` → `encode(digest(..., 'sha256'), 'hex')` via pgcrypto
- `@@ROWCOUNT` → `GET DIAGNOSTICS _rowcount = ROW_COUNT`
- `THROW` → `RAISE EXCEPTION`
- `PRINT` → `RAISE NOTICE`

## TODOs

- Ensure `pgcrypto` extension is installed: `CREATE EXTENSION IF NOT EXISTS pgcrypto;`
- Existing migrated password hashes from MSSQL `HASHBYTES` are incompatible with pgcrypto SHA-256 output format — all users will need password resets after migration.

## Dependencies

| Object | Status |
|---|---|
| `application.people` | check postgres/Application/Tables/People.sql |
