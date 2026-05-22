-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/AddCustomers.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.add_customers(
    p_current_date_time timestamp,
    p_starting_when     timestamp,
    p_end_of_time       timestamp,
    p_is_silent_mode    boolean
) RETURNS void AS $$
DECLARE
    v_number_of_customers_to_add  integer;
    v_counter                     integer := 0;
    v_delivery_method_id          integer;
    v_customer_id                 bigint;
    v_primary_contact_person_id   bigint;
    v_primary_contact_full_name   varchar(50);
    v_primary_contact_first_name  varchar(20);
    v_primary_contact_last_name   varchar(20);
    v_email_to                    varchar(200);
    v_city_id                     integer;
    v_city_name                   varchar(50);
    v_state_province_code         varchar(5);
    v_state_province_name         varchar(50);
    v_area_code                   varchar(4);
    v_buying_group_id             integer;
    v_buying_group_name           varchar(50);
    v_bg_web_domain               varchar(256);
    v_bg_email_domain             varchar(256);
    v_customer_name               varchar(100);
    v_customer_category_id        integer;
    v_credit_limit                integer;
    v_delivery_address_line1      varchar(100);
    v_delivery_address_line2      varchar(60);
    v_delivery_postal_code        varchar(10);
    v_postal_address_line1        varchar(100);
    v_postal_address_line2        varchar(60);
    v_email_address               varchar(256);
    v_phone_number                varchar(20);
    v_fax_number                  varchar(20);
BEGIN
    -- add a customer on average 1 in 25 days
    SELECT "Quantity" INTO v_number_of_customers_to_add
    FROM (VALUES (0), (0), (0), (0), (0),
                 (0), (0), (0), (0), (0),
                 (0), (0), (0), (0), (0),
                 (0), (0), (0), (0), (0),
                 (0), (0), (0), (0), (1)) AS q("Quantity")
    ORDER BY random() LIMIT 1;

    v_delivery_method_id := dataloadsimulation.get_delivery_method_id('Delivery Van');

    WHILE v_counter < v_number_of_customers_to_add LOOP
        SELECT first_name, last_name, full_name, email
        INTO v_primary_contact_first_name, v_primary_contact_last_name,
             v_primary_contact_full_name, v_email_to
        FROM dataloadsimulation.get_ficticious_name();

        IF v_primary_contact_full_name IS NULL THEN
            RETURN;
        END IF;

        SELECT city_id, city_name, state_province_code, state_province_name, area_code,
               buying_group_id, buying_group_name, web_domain, email_domain, customer_name
        INTO v_city_id, v_city_name, v_state_province_code, v_state_province_name, v_area_code,
             v_buying_group_id, v_buying_group_name, v_bg_web_domain, v_bg_email_domain, v_customer_name
        FROM dataloadsimulation.get_random_buying_group_not_in_use();

        v_customer_id             := nextval('sequences.customer_id_seq');
        v_customer_category_id    := dataloadsimulation.get_random_customer_category();
        v_credit_limit            := ceil(random() * 30)::integer * 100 + 1000;

        v_delivery_address_line1  := dataloadsimulation.get_random_street();
        v_delivery_address_line2  := dataloadsimulation.get_random_secondary_address();
        v_postal_address_line1    := dataloadsimulation.get_random_street();
        v_postal_address_line2    := dataloadsimulation.get_random_secondary_address();
        v_delivery_postal_code    := dataloadsimulation.get_bogative_postal_code(v_city_id);

        v_primary_contact_person_id := nextval('sequences.person_id_seq');
        v_email_address             := v_email_to || v_bg_email_domain;

        v_phone_number := dataloadsimulation.get_bogative_phone_number(v_area_code);
        v_fax_number   := dataloadsimulation.get_bogative_phone_number(v_area_code);

        INSERT INTO application.people
            ("PersonID", "FullName", "PreferredName", "IsPermittedToLogon", "LogonName",
             "IsExternalLogonProvider", "HashedPassword", "IsSystemUser", "IsEmployee",
             "IsSalesperson", "UserPreferences", "PhoneNumber", "FaxNumber",
             "EmailAddress", "LastEditedBy", "ValidFrom", "ValidTo")
        VALUES
            (v_primary_contact_person_id, v_primary_contact_full_name, v_primary_contact_first_name,
             false, 'NO LOGON', false, NULL, false, false,
             false, NULL, v_phone_number, v_fax_number,
             v_email_address, 1, p_current_date_time, p_end_of_time);

        INSERT INTO sales.customers
            ("CustomerID", "CustomerName", "BillToCustomerID", "CustomerCategoryID",
             "BuyingGroupID", "PrimaryContactPersonID", "AlternateContactPersonID", "DeliveryMethodID",
             "DeliveryCityID", "PostalCityID", "CreditLimit", "AccountOpenedDate",
             "StandardDiscountPercentage", "IsStatementSent", "IsOnCreditHold", "PaymentDays",
             "PhoneNumber", "FaxNumber", "DeliveryRun", "RunPosition", "WebsiteURL",
             "DeliveryAddressLine1", "DeliveryAddressLine2", "DeliveryPostalCode", "DeliveryLocation",
             "PostalAddressLine1", "PostalAddressLine2", "PostalPostalCode",
             "LastEditedBy", "ValidFrom", "ValidTo")
        VALUES
            (v_customer_id, v_customer_name, v_customer_id, v_customer_category_id,
             v_buying_group_id, v_primary_contact_person_id, NULL, v_delivery_method_id,
             v_city_id, v_city_id, v_credit_limit, CAST(p_starting_when AS date),
             0, false, false, 7,
             v_phone_number, v_fax_number, NULL, NULL, v_bg_web_domain,
             v_delivery_address_line1, v_delivery_address_line2, v_delivery_postal_code,
             dataloadsimulation.get_city_location(v_city_id),
             v_postal_address_line1, v_postal_address_line2, v_delivery_postal_code,
             1, p_current_date_time, p_end_of_time);

        v_counter := v_counter + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
