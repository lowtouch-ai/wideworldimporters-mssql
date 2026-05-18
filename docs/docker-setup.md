# Docker Setup — WideWorldImporters .NET App

## Prerequisites

- Docker Desktop installed and running
- WSL2 (if on Windows)

---

## Step 1: Build and start containers

```bash
docker compose up --build
```

This starts two containers:
- `wwi_mssql` — SQL Server 2017 on port `1433`
- `wwi_app` — ASP.NET Core 6.0 web app on port `8083`

---

## Step 2: Download and restore the database backup

The SQL Server container starts empty. Run these once after first `docker compose up`:

```bash
# Download the official WideWorldImporters backup (~122MB)
curl -L -o /tmp/WideWorldImporters-Full.bak \
  "https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak"

# Copy backup into the container
docker cp /tmp/WideWorldImporters-Full.bak wwi_mssql:/tmp/

# Restore the database
docker exec wwi_mssql /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P "Sp1d3rman!" -Q "
RESTORE DATABASE WideWorldImporters
FROM DISK='/tmp/WideWorldImporters-Full.bak'
WITH
  MOVE 'WWI_Primary'        TO '/var/opt/mssql/data/WideWorldImporters.mdf',
  MOVE 'WWI_UserData'       TO '/var/opt/mssql/data/WideWorldImporters_UserData.ndf',
  MOVE 'WWI_Log'            TO '/var/opt/mssql/data/WideWorldImporters.ldf',
  MOVE 'WWI_InMemory_Data_1' TO '/var/opt/mssql/data/WideWorldImporters_InMemory_Data_1',
  REPLACE"
```

---

## Step 3: Create the WebApi SQL login

```bash
docker exec wwi_mssql /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P "Sp1d3rman!" -Q "
USE WideWorldImporters;
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'WebApi')
    CREATE LOGIN WebApi WITH PASSWORD = 'Sp1d3rman!';
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'WebApi')
BEGIN
    CREATE USER WebApi FOR LOGIN WebApi;
    EXEC sp_addrolemember 'db_datareader', 'WebApi';
    EXEC sp_addrolemember 'db_datawriter', 'WebApi';
    GRANT EXECUTE TO WebApi;
END"
```

---

## Step 4: Deploy WebApi views

The `.bak` restore does not include the WebApi schema views. Deploy them from the source:

```bash
for f in "wwi-ssdt/wwi-ssdt/WebApi/Views/"*.sql; do
  sed 's/\xef\xbb\xbf//' "$f" | docker exec -i wwi_mssql \
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "Sp1d3rman!" -d WideWorldImporters
done
```

Then grant permissions:

```bash
docker exec wwi_mssql /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P "Sp1d3rman!" -d WideWorldImporters -Q "
GRANT SELECT ON SCHEMA::WebApi TO WebApi;
GRANT EXECUTE ON SCHEMA::WebApi TO WebApi;
GRANT SELECT ON SCHEMA::Application TO WebApi;
GRANT SELECT ON SCHEMA::Sales TO WebApi;
GRANT SELECT ON SCHEMA::Purchasing TO WebApi;
GRANT SELECT ON SCHEMA::Warehouse TO WebApi;"
```

---

## Step 5: Deploy the WebApi.Login stored procedure

```bash
docker exec wwi_mssql /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P "Sp1d3rman!" -d WideWorldImporters -Q "
CREATE PROCEDURE [WebApi].[Login](@LogonName nvarchar(256), @Password nvarchar(256))
WITH EXECUTE AS OWNER
AS BEGIN
    SELECT PersonID, PreferredName, IsSalesperson, IsEmployee,
        Territory = JSON_VALUE(CustomFields, '$.PrimarySalesTerritory')
    FROM Application.People
    WHERE IsPermittedToLogon = 1
    AND LogonName = @LogonName
END"
```

---

## Step 6: Open the app

Navigate to **http://localhost:8083**

Login with any employee email (password check is disabled in sample data):

| Email | Role |
|---|---|
| `kaylaw@wideworldimporters.com` | Salesperson |
| `hudsono@wideworldimporters.com` | Salesperson |
| `isabellar@wideworldimporters.com` | Employee |
| `sophiah@wideworldimporters.com` | Salesperson |

Password: anything (e.g. `password`)

---

## Subsequent starts

After the first setup, just run:

```bash
docker compose up
```

The database volume persists — no need to restore the backup again.

To stop:

```bash
docker compose down
```

To stop and wipe the database volume (full reset):

```bash
docker compose down -v
```

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Port already in use | Change the port in `docker-compose.yml` |
| No data in UI | Make sure you are logged in first, then hard-refresh (Ctrl+Shift+R) |
| DataTables JS error | Rebuild the image: `docker compose up --build` |
| SQL connection refused | Wait 30s for SQL Server healthcheck to pass |
