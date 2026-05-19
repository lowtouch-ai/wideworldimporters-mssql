-- Converted from: wwi-ssdt/wwi-ssdt/Security/External Sales.sql
--                  wwi-ssdt/wwi-ssdt/Security/Far West Sales.sql
--                  wwi-ssdt/wwi-ssdt/Security/Great Lakes Sales.sql
--                  wwi-ssdt/wwi-ssdt/Security/Mideast Sales.sql
--                  wwi-ssdt/wwi-ssdt/Security/New England Sales.sql
--                  wwi-ssdt/wwi-ssdt/Security/Plains Sales.sql
--                  wwi-ssdt/wwi-ssdt/Security/Rocky Mountain Sales.sql
--                  wwi-ssdt/wwi-ssdt/Security/Southeast Sales.sql
--                  wwi-ssdt/wwi-ssdt/Security/Southwest Sales.sql
--
-- Sales-territory roles used by application.determine_customer_access() for row-level security.
-- Role names must exactly match the territory names in application.state_provinces.SalesTerritory
-- concatenated with ' Sales' (e.g. territory 'Far West' → role "Far West Sales").
-- AUTHORIZATION [dbo] has no PostgreSQL equivalent — roles are database-wide, no owner needed.
-- Each block is idempotent: a duplicate_object error is silently suppressed.

DO $$ BEGIN CREATE ROLE "External Sales"; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE "Far West Sales"; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE "Great Lakes Sales"; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE "Mideast Sales"; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE "New England Sales"; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE "Plains Sales"; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE "Rocky Mountain Sales"; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE "Southeast Sales"; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE "Southwest Sales"; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
