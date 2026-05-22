-- Converted from: wwi-ssdt/wwi-ssdt/PostDeploymentScripts/pds230-ins-sales-customers.sql
-- Inserts corporate sales customers (buying groups with BuyingGroupID > 1).
-- Each buying group gets a head-office customer plus 3–200 sub-office customers
-- in distinct cities, each with their own contact person in application.people.
\echo 'Inserting sales.customers'

DO $$
DECLARE
    -- Cursor record
    rec                          RECORD;

    -- City fields (from get_random_city)
    v_city_id                    integer;
    v_city_name                  varchar(50);
    v_state_province_code        varchar(5);
    v_state_province_name        varchar(50);
    v_area_code                  varchar(4);

    -- Name fields (from get_ficticious_name)
    v_my_first_name              varchar(20);
    v_my_last_name               varchar(20);
    v_my_full_name               varchar(40);
    v_my_email                   varchar(200);

    -- Domain fields (from get_buying_group_domain)
    v_website_url                varchar(256);
    v_email_domain               varchar(256);

    -- People table constants/variables
    v_person_id                  integer;
    v_full_name                  varchar(50);
    v_preferred_name             varchar(50);
    v_is_permitted_to_logon      boolean  := false;
    v_logon_name                 varchar(50) := 'NO LOGON';
    v_is_external_logon_provider boolean  := false;
    v_hashed_password            bytea    := NULL;
    v_is_system_user             boolean  := false;
    v_is_employee                boolean  := false;
    v_is_salesperson             boolean  := false;
    v_user_preferences           text     := NULL;
    v_phone_number               varchar(20);
    v_fax_number                 varchar(20);
    v_email_address              varchar(256);
    v_last_edited_by             integer  := 1;
    v_person_main_contact        integer;
    v_person_secondary_contact   integer;
    v_loop_counter               integer;

    -- Customer table constants/variables
    v_customer_id                integer  := 0;
    v_customer_name              varchar(100);
    v_bill_to_customer_id        integer;
    v_customer_category_id       integer;
    v_delivery_method_id         integer;
    v_delivery_city_id           integer;
    v_postal_city_id             integer;
    v_credit_limit               numeric(18,2) := NULL;
    v_account_opened_date        date     := '2020-01-01';
    v_standard_discount_pct      numeric(18,3) := 0;
    v_is_statement_sent          boolean  := false;
    v_is_on_credit_hold          boolean  := false;
    v_payment_days               integer  := 7;
    v_delivery_run               varchar(5)  := '';
    v_run_position               varchar(5)  := '';
    v_delivery_address_line1     varchar(60);
    v_delivery_address_line2     varchar(60);
    v_delivery_postal_code       varchar(10);
    v_delivery_location          geography;
    v_postal_address_line1       varchar(60);
    v_postal_address_line2       varchar(60);
    v_postal_postal_code         varchar(10);

    -- Tracking
    v_corporate_category_id      integer;
    v_number_of_random_customers integer;
    v_current_random_customer    integer;
    v_city_count                 integer;

    -- Temp table substitute: array of used city IDs
    v_used_city_ids              integer[] := ARRAY[]::integer[];

BEGIN
    -- Get the highest PersonID from the People table
    SELECT MAX("PersonID") INTO v_person_id FROM application.people;

    -- Get the CustomerCategoryID for 'Corporate'
    SELECT "CustomerCategoryID" INTO v_corporate_category_id
      FROM sales.customercategories
     WHERE "CustomerCategoryName" = 'Corporate';

    -- Iterate over all active buying groups (excluding individual buyers, ID = 1)
    FOR rec IN
        SELECT "BuyingGroupID", "BuyingGroupName"
          FROM sales.buyinggroups
         WHERE "ValidTo" = '9999-12-31 23:59:59.9999999'
           AND "BuyingGroupID" > 1
    LOOP
        -- Get a random city for the head-office customer
        SELECT city_id, city_name, state_province_code, state_province_name, area_code
          INTO v_city_id, v_city_name, v_state_province_code, v_state_province_name, v_area_code
          FROM dataloadsimulation.get_random_city();

        -- Get the website/email domain for this buying group
        SELECT web_domain, email_domain
          INTO v_website_url, v_email_domain
          FROM dataloadsimulation.get_buying_group_domain(rec."BuyingGroupName");

        -- Get random payment days (shared by head office and all sub offices)
        v_payment_days := dataloadsimulation.get_random_payment_days();

        -- Pre-compute the two contact PersonIDs we are about to insert
        v_person_main_contact      := v_person_id + 1;
        v_person_secondary_contact := v_person_id + 2;

        -- Insert two contact persons for the head office
        v_loop_counter := 0;
        WHILE v_loop_counter < 2 LOOP
            -- Get a random fictitious person
            SELECT first_name, last_name, full_name, email
              INTO v_my_first_name, v_my_last_name, v_my_full_name, v_my_email
              FROM dataloadsimulation.get_ficticious_name();

            v_person_id      := v_person_id + 1;
            v_full_name      := v_my_full_name;
            v_preferred_name := v_my_first_name;
            v_email_address  := v_my_email || '@' || v_email_domain || '.com';

            -- Random phone numbers
            v_phone_number := dataloadsimulation.get_bogative_phone_number(v_area_code);
            v_fax_number   := dataloadsimulation.get_bogative_phone_number(v_area_code);

            INSERT INTO application.people
                ("PersonID", "FullName", "PreferredName",
                 "IsPermittedToLogon", "LogonName",
                 "IsExternalLogonProvider", "HashedPassword",
                 "IsSystemUser", "IsEmployee", "IsSalesperson",
                 "UserPreferences", "PhoneNumber", "FaxNumber",
                 "EmailAddress", "LastEditedBy", "ValidFrom", "ValidTo")
            VALUES
                (v_person_id, v_full_name, v_preferred_name,
                 v_is_permitted_to_logon, v_logon_name,
                 v_is_external_logon_provider, v_hashed_password,
                 v_is_system_user, v_is_employee, v_is_salesperson,
                 v_user_preferences, v_phone_number, v_fax_number,
                 v_email_address, v_last_edited_by,
                 '2020-01-01 00:00:00'::timestamp(6),
                 '9999-12-31 23:59:59.999999'::timestamp(6));

            v_loop_counter := v_loop_counter + 1;
        END LOOP; -- insert two head-office contacts

        -- Insert the Head Office customer record
        v_customer_id         := v_customer_id + 1;
        v_customer_name       := rec."BuyingGroupName" || ' (Head Office)';
        v_bill_to_customer_id := v_customer_id;   -- head office bills itself
        v_delivery_city_id    := v_city_id;
        v_postal_city_id      := v_city_id;

        v_delivery_method_id     := dataloadsimulation.get_random_delivery_method();
        v_phone_number           := dataloadsimulation.get_bogative_phone_number(v_area_code);
        v_fax_number             := dataloadsimulation.get_bogative_phone_number(v_area_code);
        v_delivery_address_line1 := dataloadsimulation.get_random_street();
        v_delivery_address_line2 := dataloadsimulation.get_random_secondary_address();
        v_postal_address_line1   := dataloadsimulation.get_random_street();
        v_postal_address_line2   := dataloadsimulation.get_random_secondary_address();
        v_delivery_location      := dataloadsimulation.get_city_location(v_city_id);
        v_delivery_postal_code   := dataloadsimulation.get_bogative_postal_code(v_city_id);
        v_postal_postal_code     := dataloadsimulation.get_bogative_postal_code(v_city_id);
        v_credit_limit           := ceil(random() * 30) * 100 + 1000;

        INSERT INTO sales.customers
            ("CustomerID", "CustomerName", "BillToCustomerID", "CustomerCategoryID",
             "BuyingGroupID", "PrimaryContactPersonID", "AlternateContactPersonID",
             "DeliveryMethodID", "DeliveryCityID", "PostalCityID",
             "CreditLimit", "AccountOpenedDate", "StandardDiscountPercentage",
             "IsStatementSent", "IsOnCreditHold", "PaymentDays",
             "PhoneNumber", "FaxNumber",
             "DeliveryRun", "RunPosition", "WebsiteURL",
             "DeliveryAddressLine1", "DeliveryAddressLine2", "DeliveryPostalCode",
             "DeliveryLocation",
             "PostalAddressLine1", "PostalAddressLine2", "PostalPostalCode",
             "LastEditedBy", "ValidFrom", "ValidTo")
        VALUES
            (v_customer_id, v_customer_name, v_bill_to_customer_id, v_corporate_category_id,
             rec."BuyingGroupID", v_person_main_contact, v_person_secondary_contact,
             v_delivery_method_id, v_delivery_city_id, v_postal_city_id,
             v_credit_limit, v_account_opened_date, v_standard_discount_pct,
             v_is_statement_sent, v_is_on_credit_hold, v_payment_days,
             v_phone_number, v_fax_number,
             v_delivery_run, v_run_position, v_website_url,
             v_delivery_address_line1, v_delivery_address_line1, v_delivery_postal_code,
             v_delivery_location,
             v_postal_address_line1, v_postal_address_line2, v_postal_postal_code,
             v_last_edited_by,
             '2020-01-01 00:00:00'::timestamp(6),
             '9999-12-31 23:59:59.999999'::timestamp(6));

        -- Insert 3–200 sub-office customers for this buying group.
        -- Each sub office uses a unique city (tracked in v_used_city_ids array).
        v_number_of_random_customers := (floor(random() * 197))::integer + 3;
        v_current_random_customer    := 2;
        v_used_city_ids              := ARRAY[]::integer[];

        WHILE v_current_random_customer <= v_number_of_random_customers LOOP

            -- Pick a city not yet used by this buying group
            LOOP
                SELECT city_id, city_name, state_province_code, state_province_name, area_code
                  INTO v_city_id, v_city_name, v_state_province_code, v_state_province_name, v_area_code
                  FROM dataloadsimulation.get_random_city();

                -- Exit once we find a city not already in our used list
                EXIT WHEN NOT (v_city_id = ANY(v_used_city_ids));
            END LOOP;

            v_used_city_ids := v_used_city_ids || v_city_id;

            -- Insert a contact person for this sub office
            SELECT first_name, last_name, full_name, email
              INTO v_my_first_name, v_my_last_name, v_my_full_name, v_my_email
              FROM dataloadsimulation.get_ficticious_name();

            v_person_id      := v_person_id + 1;
            v_full_name      := v_my_full_name;
            v_preferred_name := v_my_first_name;
            v_email_address  := v_my_email || '@' || v_email_domain || '.com';

            v_phone_number := dataloadsimulation.get_bogative_phone_number(v_area_code);
            v_fax_number   := dataloadsimulation.get_bogative_phone_number(v_area_code);

            INSERT INTO application.people
                ("PersonID", "FullName", "PreferredName",
                 "IsPermittedToLogon", "LogonName",
                 "IsExternalLogonProvider", "HashedPassword",
                 "IsSystemUser", "IsEmployee", "IsSalesperson",
                 "UserPreferences", "PhoneNumber", "FaxNumber",
                 "EmailAddress", "LastEditedBy", "ValidFrom", "ValidTo")
            VALUES
                (v_person_id, v_full_name, v_preferred_name,
                 v_is_permitted_to_logon, v_logon_name,
                 v_is_external_logon_provider, v_hashed_password,
                 v_is_system_user, v_is_employee, v_is_salesperson,
                 v_user_preferences, v_phone_number, v_fax_number,
                 v_email_address, v_last_edited_by,
                 '2020-01-01 00:00:00'::timestamp(6),
                 '9999-12-31 23:59:59.999999'::timestamp(6));

            -- The secondary contact for sub offices is the head-office primary contact
            v_person_secondary_contact := v_person_main_contact;

            -- Insert the sub-office customer record
            v_customer_id   := v_customer_id + 1;
            v_customer_name := rec."BuyingGroupName" || ' (' || v_city_name || ', ' || v_state_province_code || ')';
            v_delivery_city_id := v_city_id;
            v_postal_city_id   := v_city_id;

            v_customer_category_id   := dataloadsimulation.get_random_customer_category();
            v_delivery_method_id     := dataloadsimulation.get_random_delivery_method();
            v_phone_number           := dataloadsimulation.get_bogative_phone_number(v_area_code);
            v_fax_number             := dataloadsimulation.get_bogative_phone_number(v_area_code);
            v_delivery_address_line1 := dataloadsimulation.get_random_street();
            v_delivery_address_line2 := dataloadsimulation.get_random_secondary_address();
            v_postal_address_line1   := dataloadsimulation.get_random_street();
            v_postal_address_line2   := dataloadsimulation.get_random_secondary_address();
            v_delivery_location      := dataloadsimulation.get_city_location(v_city_id);
            v_delivery_postal_code   := dataloadsimulation.get_bogative_postal_code(v_city_id);
            v_postal_postal_code     := dataloadsimulation.get_bogative_postal_code(v_city_id);
            v_credit_limit           := ceil(random() * 30) * 100 + 1000;

            INSERT INTO sales.customers
                ("CustomerID", "CustomerName", "BillToCustomerID", "CustomerCategoryID",
                 "BuyingGroupID", "PrimaryContactPersonID", "AlternateContactPersonID",
                 "DeliveryMethodID", "DeliveryCityID", "PostalCityID",
                 "CreditLimit", "AccountOpenedDate", "StandardDiscountPercentage",
                 "IsStatementSent", "IsOnCreditHold", "PaymentDays",
                 "PhoneNumber", "FaxNumber",
                 "DeliveryRun", "RunPosition", "WebsiteURL",
                 "DeliveryAddressLine1", "DeliveryAddressLine2", "DeliveryPostalCode",
                 "DeliveryLocation",
                 "PostalAddressLine1", "PostalAddressLine2", "PostalPostalCode",
                 "LastEditedBy", "ValidFrom", "ValidTo")
            VALUES
                (v_customer_id, v_customer_name, v_bill_to_customer_id, v_customer_category_id,
                 rec."BuyingGroupID", v_person_id, v_person_secondary_contact,
                 v_delivery_method_id, v_delivery_city_id, v_postal_city_id,
                 v_credit_limit, v_account_opened_date, v_standard_discount_pct,
                 v_is_statement_sent, v_is_on_credit_hold, v_payment_days,
                 v_phone_number, v_fax_number,
                 v_delivery_run, v_run_position, v_website_url,
                 v_delivery_address_line1, v_delivery_address_line1, v_delivery_postal_code,
                 v_delivery_location,
                 v_postal_address_line1, v_postal_address_line2, v_postal_postal_code,
                 v_last_edited_by,
                 '2020-01-01 00:00:00'::timestamp(6),
                 '9999-12-31 23:59:59.999999'::timestamp(6));

            v_current_random_customer := v_current_random_customer + 1;
        END LOOP; -- sub-office customers

    END LOOP; -- buying groups

END;
$$;
