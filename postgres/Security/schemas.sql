-- Converted from: wwi-ssdt/wwi-ssdt/Security/Application.sql
--                  wwi-ssdt/wwi-ssdt/Security/DataLoadSimulation.sql
--                  wwi-ssdt/wwi-ssdt/Security/Integration.sql
--                  wwi-ssdt/wwi-ssdt/Security/PowerBI.sql
--                  wwi-ssdt/wwi-ssdt/Security/Purchasing.sql
--                  wwi-ssdt/wwi-ssdt/Security/Reports.sql
--                  wwi-ssdt/wwi-ssdt/Security/Sales.sql
--                  wwi-ssdt/wwi-ssdt/Security/Sequences.sql
--                  wwi-ssdt/wwi-ssdt/Security/Warehouse.sql
--                  wwi-ssdt/wwi-ssdt/Security/WebApi.sql
--                  wwi-ssdt/wwi-ssdt/Security/Website.sql
--
-- Authoritative schema-creation script for all WWI schemas.
-- sp_addextendedproperty → COMMENT ON SCHEMA.

CREATE SCHEMA IF NOT EXISTS application;
COMMENT ON SCHEMA application IS 'Tables common across the application. Used for categorization and lookup lists, system parameters and people (users and contacts)';

CREATE SCHEMA IF NOT EXISTS dataloadsimulation;
COMMENT ON SCHEMA dataloadsimulation IS 'Tables and procedures used only during simulated data loading operations';

CREATE SCHEMA IF NOT EXISTS integration;
COMMENT ON SCHEMA integration IS 'Tables and procedures required for integration with the data warehouse';

CREATE SCHEMA IF NOT EXISTS powerbi;
COMMENT ON SCHEMA powerbi IS 'Views and stored procedures that provide the only access for the Power BI dashboard system';

CREATE SCHEMA IF NOT EXISTS purchasing;
COMMENT ON SCHEMA purchasing IS 'Details of suppliers and of purchasing of stock items';

CREATE SCHEMA IF NOT EXISTS reports;
COMMENT ON SCHEMA reports IS 'Views and stored procedures that provide the only access for the reporting system';

CREATE SCHEMA IF NOT EXISTS sales;
COMMENT ON SCHEMA sales IS 'Details of customers, salespeople, and of sales of stock items';

CREATE SCHEMA IF NOT EXISTS sequences;
COMMENT ON SCHEMA sequences IS 'Holds sequences used by all tables in the application';

CREATE SCHEMA IF NOT EXISTS warehouse;
COMMENT ON SCHEMA warehouse IS 'Details of stock items, their holdings and transactions';

CREATE SCHEMA IF NOT EXISTS webapi;
COMMENT ON SCHEMA webapi IS 'Views and stored procedures that provide the only access for the application Web API';

CREATE SCHEMA IF NOT EXISTS website;
COMMENT ON SCHEMA website IS 'Views and stored procedures that provide the only access for the application website';
