-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/MakeTemporalChanges.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.make_temporal_changes(
    p_current_date_time timestamp,
    p_starting_when     timestamp,
    p_end_of_time       timestamp,
    p_is_silent_mode    boolean
) RETURNS void AS $$
DECLARE
    v_counter         integer;
    v_rows_to_modify  integer;
    v_staff_member    integer;
BEGIN
    SELECT "PersonID" INTO v_staff_member
    FROM application.people
    WHERE "IsEmployee" <> false
    ORDER BY random()
    LIMIT 1;

    -- Annual population updates on July 1st
    IF EXTRACT(DAY FROM p_starting_when)::integer = 1 AND EXTRACT(MONTH FROM p_starting_when)::integer = 7 THEN
        v_counter := 0;
        v_rows_to_modify := ceil(random() * 20)::integer;
        WHILE v_counter < v_rows_to_modify LOOP
            UPDATE application.cities
            SET "LatestRecordedPopulation" = "LatestRecordedPopulation" * 1.04,
                "LastEditedBy" = v_staff_member,
                "ValidFrom" = p_starting_when
            WHERE "CityID" = (SELECT "CityID" FROM application.cities ORDER BY random() LIMIT 1);
            v_counter := v_counter + 1;
        END LOOP;

        v_counter := 0;
        v_rows_to_modify := ceil(random() * 20)::integer;
        WHILE v_counter < v_rows_to_modify LOOP
            UPDATE application.stateprovinces
            SET "LatestRecordedPopulation" = "LatestRecordedPopulation" * 1.04,
                "LastEditedBy" = v_staff_member,
                "ValidFrom" = p_starting_when
            WHERE "StateProvinceID" = (SELECT "StateProvinceID" FROM application.stateprovinces ORDER BY random() LIMIT 1);
            v_counter := v_counter + 1;
        END LOOP;

        v_counter := 0;
        v_rows_to_modify := ceil(random() * 20)::integer;
        WHILE v_counter < v_rows_to_modify LOOP
            UPDATE application.countries
            SET "LatestRecordedPopulation" = "LatestRecordedPopulation" * 1.04,
                "LastEditedBy" = v_staff_member,
                "ValidFrom" = p_starting_when
            WHERE "CountryID" = (SELECT "CountryID" FROM application.countries ORDER BY random() LIMIT 1);
            v_counter := v_counter + 1;
        END LOOP;
    END IF;

    IF CAST(p_starting_when AS date) = '2021-01-01' THEN
        UPDATE application.deliverymethods
        SET "DeliveryMethodName" = 'Chilled Van',
            "LastEditedBy" = v_staff_member,
            "ValidFrom" = p_starting_when
        WHERE "DeliveryMethodName" = 'Van with Chiller';
    END IF;

    IF CAST(p_starting_when AS date) = '2022-01-01' THEN
        UPDATE application.paymentmethods
        SET "PaymentMethodName" = 'Credit-Card',
            "LastEditedBy" = v_staff_member,
            "ValidFrom" = p_starting_when
        WHERE "PaymentMethodName" = 'Credit Card';

        INSERT INTO application.transactiontypes
            ("TransactionTypeName", "LastEditedBy", "ValidFrom", "ValidTo")
        VALUES ('Contra', v_staff_member, p_starting_when, p_end_of_time);

        UPDATE application.transactiontypes
        SET "TransactionTypeName" = 'Customer Contra',
            "LastEditedBy" = v_staff_member,
            "ValidFrom" = p_starting_when + interval '5 minutes'
        WHERE "TransactionTypeName" = 'Contra';

        UPDATE warehouse.colors
        SET "ColorName" = 'Steel Gray',
            "LastEditedBy" = v_staff_member,
            "ValidFrom" = p_starting_when
        WHERE "ColorName" = 'Gray';

        INSERT INTO warehouse.packagetypes
            ("PackageTypeName", "LastEditedBy", "ValidFrom", "ValidTo")
        VALUES ('Bin', v_staff_member, p_starting_when, p_end_of_time);

        DELETE FROM warehouse.packagetypes WHERE "PackageTypeName" = 'Bin';

        UPDATE warehouse.stockgroups
        SET "StockGroupName" = 'Furry Footwear',
            "LastEditedBy" = v_staff_member,
            "ValidFrom" = p_starting_when
        WHERE "StockGroupName" = 'Footwear';
    END IF;

    IF CAST(p_starting_when AS date) = '2021-01-01' THEN
        UPDATE purchasing.suppliercategories
        SET "SupplierCategoryName" = 'Courier Services Supplier',
            "LastEditedBy" = v_staff_member,
            "ValidFrom" = p_starting_when
        WHERE "SupplierCategoryName" = 'Courier';
    END IF;

    IF CAST(p_starting_when AS date) = '2020-07-01' THEN
        INSERT INTO sales.customercategories
            ("CustomerCategoryName", "LastEditedBy", "ValidFrom", "ValidTo")
        VALUES ('Retailer', 1, p_starting_when, p_end_of_time);

        UPDATE sales.customercategories
        SET "CustomerCategoryName" = 'General Retailer',
            "LastEditedBy" = v_staff_member,
            "ValidFrom" = p_starting_when + interval '15 minutes'
        WHERE "CustomerCategoryName" = 'Retailer';
    END IF;

    IF EXTRACT(DAY FROM p_starting_when)::integer = 1 AND EXTRACT(MONTH FROM p_starting_when)::integer = 7 THEN
        v_counter := 0;
        v_rows_to_modify := ceil(random() * 20)::integer;
        WHILE v_counter < v_rows_to_modify LOOP
            UPDATE sales.customers
            SET "CreditLimit" = "CreditLimit" * 1.05,
                "LastEditedBy" = v_staff_member,
                "ValidFrom" = p_starting_when
            WHERE "CustomerID" = (SELECT "CustomerID" FROM sales.customers WHERE "CreditLimit" > 0 ORDER BY random() LIMIT 1);
            v_counter := v_counter + 1;
        END LOOP;
    END IF;
END;
$$ LANGUAGE plpgsql;
