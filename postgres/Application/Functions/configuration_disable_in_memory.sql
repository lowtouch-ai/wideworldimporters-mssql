-- Converted from: wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_DisableInMemory.sql
-- NOTE: SQL Server In-Memory OLTP (memory-optimized tables, natively compiled SPs, table types)
--       has no equivalent in standard PostgreSQL. The WideWorldImporters in-memory objects
--       (Website.InvoiceCustomerOrders, Website.InsertCustomerOrders,
--        Website.RecordColdRoomTemperatures, memory-optimized table types) are managed as
--       regular PL/pgSQL functions in this migration. This function is a no-op stub.
CREATE SCHEMA IF NOT EXISTS application;

CREATE OR REPLACE FUNCTION application.configuration_disable_in_memory() RETURNS void AS $$
BEGIN
    RAISE NOTICE 'In-Memory OLTP is not supported in PostgreSQL. No action taken.';
END;
$$ LANGUAGE plpgsql;
