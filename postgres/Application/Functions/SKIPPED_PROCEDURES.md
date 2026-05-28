# Application schema — skipped stored procedures

These 12 stored procedures are MSSQL-specific configuration/admin scripts with no meaningful PostgreSQL equivalent. They configure features that either do not exist in PostgreSQL or require entirely different tooling.

| Stored Procedure | Reason skipped | PostgreSQL equivalent |
|---|---|---|
| `Configuration_ApplyAuditing` | Dynamic SQL + MSSQL Audit objects | Use `pgaudit` extension |
| `Configuration_RemoveAuditing` | Dynamic SQL + MSSQL Audit objects | Use `pgaudit` extension |
| `Configuration_ApplyColumnstoreIndexing` | Columnstore indexes have no PG equivalent | Omit or use `BRIN`/`GIN` where appropriate |
| `Configuration_RemoveColumnstoreIndexing` | Same as above | N/A |
| `Configuration_ApplyFullTextIndexing` | MSSQL Full-Text Search catalog | Use `tsvector`/`GIN` indexes |
| `Configuration_ApplyPartitioning` | MSSQL partition schemes/functions | Use PG declarative table partitioning |
| `Configuration_ApplyRowLevelSecurity` | Dynamic SQL creating MSSQL security predicates | Use PostgreSQL `CREATE POLICY` + `ALTER TABLE ENABLE ROW LEVEL SECURITY` |
| `Configuration_RemoveRowLevelSecurity` | Same as above | `DROP POLICY` / `ALTER TABLE DISABLE ROW LEVEL SECURITY` |
| `Configuration_EnableInMemory` | MSSQL In-Memory OLTP (XTP) — no PG equivalent | N/A |
| `Configuration_DisableInMemory` | Same as above | N/A |
| `Configuration_ConfigureForEnterpriseEdition` | Calls other skipped SPs | N/A |
| `Configuration_PrepareForAzureStandard` | Calls other skipped SPs | N/A |
