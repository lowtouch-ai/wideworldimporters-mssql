-- Authoritative schema-creation script for all WWI schemas.
-- Converted from wwi-ssdt/wwi-ssdt/Security/<Schema>.sql files.
-- All statements are idempotent.

CREATE SCHEMA IF NOT EXISTS application;
COMMENT ON SCHEMA application IS 'Tables common across the application. Used for categorization and lookup lists, system parameters and people (users and contacts)';

CREATE SCHEMA IF NOT EXISTS dataloadsimulation;
COMMENT ON SCHEMA dataloadsimulation IS 'Tables and procedures used only during simulated data loading operations';

CREATE SCHEMA IF NOT EXISTS integration;
COMMENT ON SCHEMA integration IS 'Tables and procedures required for integration with the data warehouse';

CREATE SCHEMA IF NOT EXISTS purchasing;
COMMENT ON SCHEMA purchasing IS 'Details of suppliers and of purchasing of stock items';

CREATE SCHEMA IF NOT EXISTS sales;
COMMENT ON SCHEMA sales IS 'Details of customers, orders, and invoices';

CREATE SCHEMA IF NOT EXISTS sequences;
COMMENT ON SCHEMA sequences IS 'Holds all sequences used across the WideWorldImporters database';

CREATE SCHEMA IF NOT EXISTS warehouse;
COMMENT ON SCHEMA warehouse IS 'Details of stock items, including holding details';

CREATE SCHEMA IF NOT EXISTS webapi;
COMMENT ON SCHEMA webapi IS 'Views and stored procedures that provide the only access for the WebApi system';

CREATE SCHEMA IF NOT EXISTS website;
COMMENT ON SCHEMA website IS 'Views and stored procedures that provide the only access for the Website system';
