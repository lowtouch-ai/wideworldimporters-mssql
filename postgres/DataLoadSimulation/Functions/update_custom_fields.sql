-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/UpdateCustomFields.sql
-- Note: sys.syslanguages replaced with a hardcoded language list; JSON_MODIFY → jsonb_set.
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.update_custom_fields(
    p_current_date date
) RETURNS void AS $$
DECLARE
    v_starting_when         timestamp;
    v_employee_id           integer;
    v_is_salesperson        boolean;
    v_custom_fields         text;
    v_job_title             varchar(50);
    v_number_of_languages   integer;
    v_language_counter      integer;
    v_language_name         varchar(50);
    rec                     record;
BEGIN
    v_starting_when := p_current_date::timestamp + interval '23 hours';

    -- Populate custom data for stock items
    UPDATE warehouse.stockitems
    SET "CustomFields" = '{ "CountryOfManufacture": '
                       || CASE WHEN "IsChillerStock" <> false THEN '"USA", "ShelfLife": "7 days"'
                               WHEN "StockItemName" LIKE '%USB food%' THEN '"Japan"'
                               ELSE '"China"'
                          END
                       || ', "Tags": []'
                       || CASE WHEN "Size" IN ('S', 'XS', 'XXS', '3XS') THEN ', "Range": "Children"'
                               WHEN "Size" IN ('M') THEN ', "Range": "Teens/Young Adult"'
                               WHEN "Size" IN ('L', 'XL', 'XXL', '3XL', '4XL', '5XL', '6XL', '7XL') THEN ', "Range": "Adult"'
                               ELSE ''
                          END
                       || CASE WHEN "StockItemName" LIKE 'RC %' THEN ', "MinimumAge": "10"'
                               ELSE ''
                          END
                       || ' }',
        "ValidFrom" = v_starting_when;

    v_starting_when := v_starting_when + interval '1 minute';
    UPDATE warehouse.stockitems
    SET "CustomFields" = jsonb_set("CustomFields"::jsonb, '{Tags}',
                             ("CustomFields"::jsonb->'Tags') || '["Radio Control"]'::jsonb)::text,
        "ValidFrom" = v_starting_when
    WHERE "StockItemName" LIKE 'RC %';

    v_starting_when := v_starting_when + interval '1 minute';
    UPDATE warehouse.stockitems
    SET "CustomFields" = jsonb_set("CustomFields"::jsonb, '{Tags}',
                             ("CustomFields"::jsonb->'Tags') || '["Realistic Sound"]'::jsonb)::text,
        "ValidFrom" = v_starting_when
    WHERE "StockItemName" LIKE 'RC %';

    v_starting_when := v_starting_when + interval '1 minute';
    UPDATE warehouse.stockitems
    SET "CustomFields" = jsonb_set("CustomFields"::jsonb, '{Tags}',
                             ("CustomFields"::jsonb->'Tags') || '["Vintage"]'::jsonb)::text,
        "ValidFrom" = v_starting_when
    WHERE "StockItemName" LIKE '%vintage%';

    v_starting_when := v_starting_when + interval '1 minute';
    UPDATE warehouse.stockitems
    SET "CustomFields" = jsonb_set("CustomFields"::jsonb, '{Tags}',
                             ("CustomFields"::jsonb->'Tags') || '["Halloween Fun"]'::jsonb)::text,
        "ValidFrom" = v_starting_when
    WHERE "StockItemName" LIKE '%halloween%';

    v_starting_when := v_starting_when + interval '1 minute';
    UPDATE warehouse.stockitems
    SET "CustomFields" = jsonb_set("CustomFields"::jsonb, '{Tags}',
                             ("CustomFields"::jsonb->'Tags') || '["Super Value"]'::jsonb)::text,
        "ValidFrom" = v_starting_when
    WHERE "StockItemName" LIKE '%pack of%';

    v_starting_when := v_starting_when + interval '1 minute';
    UPDATE warehouse.stockitems
    SET "CustomFields" = jsonb_set("CustomFields"::jsonb, '{Tags}',
                             ("CustomFields"::jsonb->'Tags') || '["So Realistic"]'::jsonb)::text,
        "ValidFrom" = v_starting_when
    WHERE "StockItemName" LIKE '%ride on%';

    v_starting_when := v_starting_when + interval '1 minute';
    UPDATE warehouse.stockitems
    SET "CustomFields" = jsonb_set("CustomFields"::jsonb, '{Tags}',
                             ("CustomFields"::jsonb->'Tags') || '["Comfortable"]'::jsonb)::text,
        "ValidFrom" = v_starting_when
    WHERE "StockItemName" LIKE '%slipper%';

    v_starting_when := v_starting_when + interval '1 minute';
    UPDATE warehouse.stockitems
    SET "CustomFields" = jsonb_set("CustomFields"::jsonb, '{Tags}',
                             ("CustomFields"::jsonb->'Tags') || '["Long Battery Life"]'::jsonb)::text,
        "ValidFrom" = v_starting_when
    WHERE "StockItemName" LIKE '%slipper%';

    v_starting_when := v_starting_when + interval '1 minute';
    UPDATE warehouse.stockitems
    SET "CustomFields" = jsonb_set("CustomFields"::jsonb, '{Tags}',
                             ("CustomFields"::jsonb->'Tags')
                             || jsonb_build_array(CASE WHEN "StockItemID" % 2 = 0 THEN '32GB' ELSE '16GB' END))::text,
        "ValidFrom" = v_starting_when
    WHERE "StockItemName" LIKE '%USB food%';

    v_starting_when := v_starting_when + interval '1 minute';
    UPDATE warehouse.stockitems
    SET "CustomFields" = jsonb_set("CustomFields"::jsonb, '{Tags}',
                             ("CustomFields"::jsonb->'Tags') || '["Comedy"]'::jsonb)::text,
        "ValidFrom" = v_starting_when
    WHERE "StockItemName" LIKE '%joke%';

    v_starting_when := v_starting_when + interval '1 minute';
    UPDATE warehouse.stockitems
    SET "CustomFields" = jsonb_set("CustomFields"::jsonb, '{Tags}',
                             ("CustomFields"::jsonb->'Tags') || '["USB Powered"]'::jsonb)::text,
        "ValidFrom" = v_starting_when
    WHERE "StockItemName" LIKE '%USB%';

    v_starting_when := v_starting_when + interval '1 minute';
    UPDATE warehouse.stockitems AS si
    SET "CustomFields" = jsonb_set(si."CustomFields"::jsonb, '{Tags}',
                             (si."CustomFields"::jsonb->'Tags') || '["Limited Stock"]'::jsonb)::text,
        "ValidFrom" = v_starting_when
    WHERE EXISTS (SELECT 1
                  FROM warehouse.stockitemstockgroups AS sisg
                  INNER JOIN warehouse.stockgroups AS sg ON sisg."StockGroupID" = sg."StockGroupID"
                  WHERE si."StockItemID" = sisg."StockItemID"
                    AND sg."StockGroupName" LIKE '%Packaging%');

    -- Populate custom data for employees and salespeople
    v_starting_when := v_starting_when + interval '1 minute';

    FOR rec IN
        SELECT "PersonID", "IsSalesperson"
        FROM application.people
        WHERE "IsEmployee" <> false
    LOOP
        v_employee_id    := rec."PersonID";
        v_is_salesperson := rec."IsSalesperson";
        v_custom_fields  := '{ "OtherLanguages": [] }';

        v_number_of_languages := floor(random() * 4)::integer;
        v_language_counter    := 0;

        CREATE TEMP TABLE other_languages_tmp (language_name varchar(50)) ON COMMIT DELETE ROWS;

        WHILE v_language_counter < v_number_of_languages LOOP
            -- sys.syslanguages replaced with a representative subset of world languages
            SELECT lang INTO v_language_name
            FROM (VALUES
                ('German'), ('French'), ('Spanish'), ('Portuguese'), ('Italian'),
                ('Dutch'), ('Polish'), ('Russian'), ('Japanese'), ('Korean'),
                ('Chinese'), ('Arabic'), ('Hindi'), ('Turkish'), ('Swedish'),
                ('Norwegian'), ('Danish'), ('Finnish'), ('Czech'), ('Greek'),
                ('Hungarian'), ('Romanian'), ('Vietnamese'), ('Thai'), ('Indonesian')
            ) AS t(lang)
            WHERE lang NOT LIKE '%Chinese%' OR lang = 'Chinese'
            ORDER BY random() LIMIT 1;

            IF v_language_name LIKE '%Chinese%' THEN
                v_language_name := 'Chinese';
            END IF;

            IF NOT EXISTS (SELECT 1 FROM other_languages_tmp WHERE language_name = v_language_name) THEN
                INSERT INTO other_languages_tmp (language_name) VALUES (v_language_name);
                v_custom_fields := jsonb_set(v_custom_fields::jsonb, '{OtherLanguages}',
                                       (v_custom_fields::jsonb->'OtherLanguages') || to_json(v_language_name)::jsonb)::text;
            END IF;

            v_language_counter := v_language_counter + 1;
        END LOOP;

        DROP TABLE IF EXISTS other_languages_tmp;

        v_custom_fields := jsonb_set(
            v_custom_fields::jsonb, '{HireDate}',
            to_json(to_char('2020-01-01'::date - (ceil(random() * 2000)::integer + 100),
                            'YYYY-MM-DD"T"HH24:MI:SS'))::jsonb
        )::text;

        v_job_title := 'Team Member';
        v_job_title := CASE
            WHEN random() < 0.05 THEN 'General Manager'
            WHEN random() < 0.1  THEN 'Manager'
            WHEN random() < 0.15 THEN 'Accounts Controller'
            WHEN random() < 0.2  THEN 'Warehouse Supervisor'
            ELSE v_job_title
        END;
        v_custom_fields := jsonb_set(v_custom_fields::jsonb, '{Title}', to_json(v_job_title)::jsonb)::text;

        IF v_is_salesperson THEN
            v_custom_fields := jsonb_set(
                v_custom_fields::jsonb, '{PrimarySalesTerritory}',
                to_json((SELECT "SalesTerritory" FROM application.stateprovinces ORDER BY random() LIMIT 1))::jsonb
            )::text;
            v_custom_fields := jsonb_set(
                v_custom_fields::jsonb, '{CommissionRate}',
                to_json(CAST(CAST(random() * 5 AS numeric(18,2)) AS varchar(20)))::jsonb
            )::text;
        END IF;

        UPDATE application.people
        SET "CustomFields" = v_custom_fields,
            "ValidFrom"    = v_starting_when
        WHERE "PersonID" = v_employee_id;
    END LOOP;

    -- Set user preferences
    v_starting_when := v_starting_when + interval '1 minute';

    UPDATE application.people
    SET "UserPreferences" = '{"theme":"'
                          || CASE ("PersonID" % 7)
                                 WHEN 0 THEN 'ui-darkness'
                                 WHEN 1 THEN 'blitzer'
                                 WHEN 2 THEN 'humanity'
                                 WHEN 3 THEN 'dark-hive'
                                 WHEN 4 THEN 'ui-darkness'
                                 WHEN 5 THEN 'le-frog'
                                 WHEN 6 THEN 'black-tie'
                                 ELSE 'ui-lightness'
                             END
                          || '","dateFormat":"'
                          || CASE ("PersonID" % 10)
                                 WHEN 0 THEN 'mm/dd/yy'
                                 WHEN 1 THEN 'yy-mm-dd'
                                 WHEN 2 THEN 'dd/mm/yy'
                                 WHEN 3 THEN 'DD, MM d, yy'
                                 WHEN 4 THEN 'dd/mm/yy'
                                 WHEN 5 THEN 'dd/mm/yy'
                                 WHEN 6 THEN 'mm/dd/yy'
                                 ELSE 'mm/dd/yy'
                             END
                          || '","timeZone": "PST"'
                          || ',"table":{"pagingType":"'
                          || CASE ("PersonID" % 5)
                                 WHEN 0 THEN 'numbers'
                                 WHEN 1 THEN 'full_numbers'
                                 WHEN 2 THEN 'full'
                                 WHEN 3 THEN 'simple_numbers'
                                 ELSE 'simple'
                             END
                          || '","pageLength": '
                          || CASE ("PersonID" % 5)
                                 WHEN 0 THEN '10'
                                 WHEN 1 THEN '25'
                                 WHEN 2 THEN '50'
                                 WHEN 3 THEN '10'
                                 ELSE '10'
                             END
                          || '},"favoritesOnDashboard":true}',
        "ValidFrom" = v_starting_when
    WHERE "UserPreferences" IS NOT NULL;
END;
$$ LANGUAGE plpgsql;
