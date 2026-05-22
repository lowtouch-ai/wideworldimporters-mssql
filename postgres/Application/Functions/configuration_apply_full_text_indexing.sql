-- Converted from: wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_ApplyFullTextIndexing.sql
-- NOTE: MSSQL FULLTEXT INDEX / FREETEXTTABLE → PostgreSQL GIN indexes on tsvector expressions.
--       The five Website search SPs that were inline in the MSSQL version are managed as
--       separate converted functions in postgres/Website/Functions/ and are not recreated here.
-- NOTE: CustomFields / OtherLanguages / Tags are cast to text to support jsonb column types.
CREATE SCHEMA IF NOT EXISTS application;

CREATE OR REPLACE FUNCTION application.configuration_apply_full_text_indexing() RETURNS void AS $$
BEGIN
    -- Application.People: SearchName + CustomFields + OtherLanguages
    CREATE INDEX IF NOT EXISTS idx_gin_people_fts
        ON application.people
        USING GIN (
            to_tsvector('english',
                coalesce("SearchName", '') || ' ' ||
                coalesce("CustomFields"::text, '') || ' ' ||
                coalesce("OtherLanguages"::text, '')
            )
        );

    -- Sales.Customers: CustomerName
    CREATE INDEX IF NOT EXISTS idx_gin_customers_fts
        ON sales.customers
        USING GIN (to_tsvector('english', coalesce("CustomerName", '')));

    -- Purchasing.Suppliers: SupplierName
    CREATE INDEX IF NOT EXISTS idx_gin_suppliers_fts
        ON purchasing.suppliers
        USING GIN (to_tsvector('english', coalesce("SupplierName", '')));

    -- Warehouse.StockItems: SearchDetails + CustomFields + Tags
    CREATE INDEX IF NOT EXISTS idx_gin_stockitems_fts
        ON warehouse.stockitems
        USING GIN (
            to_tsvector('english',
                coalesce("SearchDetails"::text, '') || ' ' ||
                coalesce("CustomFields"::text, '') || ' ' ||
                coalesce("Tags"::text, '')
            )
        );

    RAISE NOTICE 'Full text GIN indexes successfully created';
END;
$$ LANGUAGE plpgsql;
