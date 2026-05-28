-- Simplified customer seed: one head-office customer per buying group (IDs 2-15)
-- Original T-SQL used GetFicticiousName/GetRandomCity which have no PostgreSQL equivalent.
-- DeliveryCityID/PostalCityID = 30378 (San Francisco), DeliveryMethodID = 7 (Courier)

DO $body$
DECLARE
    v_currentdatetime timestamp := '2020-01-01';
    v_endoftime timestamp := '9999-12-31 23:59:59.999999';
    v_bg_id integer;
    v_bg_name varchar(100);
    v_customer_id integer := 0;
    v_corp_cat_id integer;
    v_city_id integer := 30378;
    v_delivery_method_id integer := 7;
    v_person_id integer;
BEGIN
    SELECT MAX(PersonID) INTO v_person_id FROM application.people;
    SELECT CustomerCategoryID INTO v_corp_cat_id FROM sales.customercategories
     WHERE CustomerCategoryName = 'Corporate';

    FOR v_bg_id, v_bg_name IN
        SELECT BuyingGroupID, BuyingGroupName FROM sales.buyinggroups
         WHERE ValidTo = '9999-12-31 23:59:59.999999' AND BuyingGroupID > 1
         ORDER BY BuyingGroupID
    LOOP
        v_customer_id := v_customer_id + 1;

        -- Insert a contact person for this buying group
        v_person_id := v_person_id + 1;
        INSERT INTO application.people
          (PersonID, FullName, PreferredName, IsPermittedToLogon, LogonName,
           IsExternalLogonProvider, HashedPassword, IsSystemUser, IsEmployee,
           IsSalesperson, UserPreferences, PhoneNumber, FaxNumber,
           EmailAddress, LastEditedBy, ValidFrom, ValidTo)
        VALUES
          (v_person_id, v_bg_name || ' Contact', 'Contact',
           false, 'NO LOGON', false, NULL, false, false, false,
           NULL, '(415) 555-0100', '(415) 555-0101',
           'contact@' || lower(regexp_replace(v_bg_name, '[^a-zA-Z0-9]', '', 'g')) || '.example.com',
           1, v_currentdatetime, v_endoftime);

        INSERT INTO sales.customers
          (CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID,
           BuyingGroupID, PrimaryContactPersonID, AlternateContactPersonID,
           DeliveryMethodID, DeliveryCityID, PostalCityID,
           CreditLimit, AccountOpenedDate, StandardDiscountPercentage,
           IsStatementSent, IsOnCreditHold, PaymentDays,
           PhoneNumber, FaxNumber,
           DeliveryRun, RunPosition, WebsiteURL,
           DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation,
           PostalAddressLine1, PostalAddressLine2, PostalPostalCode,
           LastEditedBy, ValidFrom, ValidTo)
        VALUES
          (v_customer_id, v_bg_name || ' (Head Office)', v_customer_id, v_corp_cat_id,
           v_bg_id, v_person_id, NULL,
           v_delivery_method_id, v_city_id, v_city_id,
           NULL, '2020-01-01', 0,
           false, false, 7,
           '(415) 555-0100', '(415) 555-0101',
           '', '', 'http://www.' || lower(regexp_replace(v_bg_name, '[^a-zA-Z0-9]', '', 'g')) || '.com',
           '100 Main Street', NULL, '94101', NULL,
           'PO Box ' || v_customer_id, NULL, '94101',
           1, v_currentdatetime, v_endoftime);
    END LOOP;
END;
$body$;
