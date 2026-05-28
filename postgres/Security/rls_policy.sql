-- Converted from: wwi-ssdt/wwi-ssdt/Security/FilterCustomersBySalesTerritoryRole.sql
--
-- MSSQL CREATE SECURITY POLICY has no direct PostgreSQL DDL equivalent.
-- The equivalent PostgreSQL row-level security policies are created dynamically
-- by calling application.configuration_apply_row_level_security(), which was
-- converted from Application/Stored Procedures/Configuration_ApplyRowLevelSecurity.sql.
--
-- That function:
--   1. Enables RLS on sales.customers
--   2. Creates policy filter_customers_by_territory (FOR SELECT USING ...)
--   3. Creates policy block_customers_update_by_territory (FOR UPDATE WITH CHECK ...)
-- Both policies invoke application.determine_customer_access("DeliveryCityID"),
-- matching the FILTER and BLOCK predicates in the MSSQL source.
--
-- Run this script once after the application and sales schemas are fully deployed,
-- and after the sales-territory roles in roles.sql have been created.

SELECT application.configuration_apply_row_level_security();
