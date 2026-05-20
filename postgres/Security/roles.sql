-- Sales-territory roles used by application.determine_customer_access() for row-level security.
-- Role names must exactly match the territory names in application.StateProvinces.SalesTerritory
-- concatenated with ' Sales' (e.g. territory 'Far West' → role "Far West Sales").
-- Each block is idempotent: a duplicate_object error is silently suppressed.

DO $$ BEGIN CREATE ROLE "External Sales";      EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE "Far West Sales";       EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE "Great Lakes Sales";    EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE "Mideast Sales";        EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE "New England Sales";    EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE "Plains Sales";         EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE "Rocky Mountain Sales"; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE "Southeast Sales";      EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE "Southwest Sales";      EXCEPTION WHEN duplicate_object THEN NULL; END $$;
