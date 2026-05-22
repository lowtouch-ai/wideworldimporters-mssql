-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/DailyProcessToCreateHistory.sql
-- Note: SET DATEFIRST 7 removed; DATEPART(weekday) adapted to PostgreSQL DOW (0=Sunday, 6=Saturday).
-- Note: DATENAME/CONVERT date formatting → to_char; DATEFROMPARTS → make_date; DATEDIFF → date subtraction.
-- Note: Application.Configuration_ApplyRowLevelSecurity and Sequences.ReseedAllSequences called via PERFORM.
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.daily_process_to_create_history(
    p_start_date                                date,
    p_end_date                                  date,
    p_average_number_of_customer_orders_per_day integer DEFAULT 30,
    p_saturday_percentage_of_normal_work_day    integer,
    p_sunday_percentage_of_normal_work_day      integer,
    p_update_custom_fields                      boolean,
    p_is_silent_mode                            boolean,
    p_are_dates_printed                         boolean,
    p_min_yearly_growth_percent                 integer DEFAULT -5,
    p_max_yearly_growth_percent                 integer DEFAULT 15,
    p_min_seasonal_variation_percent            integer DEFAULT -10,
    p_max_seasonal_variation_percent            integer DEFAULT 30,
    p_max_daily_variation_percent               integer DEFAULT 20
) RETURNS void AS $$
DECLARE
    v_current_date_time              timestamp;
    v_end_of_time                    timestamp := '9999-12-31 23:59:59.999999';
    v_starting_when                  timestamp;
    v_old_number_of_customer_orders  integer;
    v_number_of_customer_orders      integer;
    v_is_weekday                     boolean;
    v_is_saturday                    boolean;
    v_is_sunday                      boolean;
    v_is_monday                      boolean;
    v_weekday                        integer;
    v_date_message                   varchar(256);
    v_current_year                   integer;
    v_current_season                 smallint;
    v_yearly_variation               double precision;
    v_seasonal_variation             double precision;
    v_x                              double precision;
    v_season_effect                  double precision;
    v_yearly_effect                  double precision;
    v_daily_effect                   double precision;
BEGIN
    v_current_date_time := p_start_date;

    -- verify whether orders exist and compute average orders per weekday in the most recent year
    IF EXISTS (SELECT 1 FROM sales.orders) THEN
        SELECT AVG(t.order_count) INTO v_old_number_of_customer_orders
        FROM (
            SELECT COUNT(*) AS order_count
            FROM sales.orders
            WHERE EXTRACT(YEAR FROM "OrderDate")::integer =
                  EXTRACT(YEAR FROM (SELECT MAX("OrderDate") FROM sales.orders))::integer
              AND EXTRACT(DOW FROM "OrderDate") NOT IN (0, 6)
              AND "BackorderOrderID" IS NULL
            GROUP BY "OrderDate"
        ) t;
    ELSE
        v_old_number_of_customer_orders := p_average_number_of_customer_orders_per_day;
    END IF;

    -- pre-compute seasonal variation entries for each year/season in the date range
    v_current_year := EXTRACT(YEAR FROM p_start_date)::integer;
    WHILE v_current_year <= EXTRACT(YEAR FROM p_end_date)::integer LOOP
        v_current_season := 1;
        v_yearly_variation := 1.0 + (p_min_yearly_growth_percent
            + random() * (p_max_yearly_growth_percent - p_min_yearly_growth_percent)::double precision) / 100.0;

        WHILE v_current_season <= 4 LOOP
            IF NOT EXISTS (SELECT 1 FROM dataloadsimulation.seasonvariation
                           WHERE "Year" = v_current_year AND "Season" = v_current_season) THEN
                v_seasonal_variation := 1.0 + (p_min_seasonal_variation_percent
                    + random() * (p_max_seasonal_variation_percent - p_min_seasonal_variation_percent)::double precision) / 100.0;
                IF v_current_season % 2 = 1 THEN
                    v_seasonal_variation := 1.0 / v_seasonal_variation;
                END IF;

                INSERT INTO dataloadsimulation.seasonvariation ("Year", "Season", "YearlyVariation", "SeasonalVariation")
                VALUES (v_current_year, v_current_season, v_yearly_variation, v_seasonal_variation);
            END IF;
            v_current_season := v_current_season + 1;
        END LOOP;
        v_current_year := v_current_year + 1;
    END LOOP;

    PERFORM dataloadsimulation.deactivate_temporal_tables_before_data_load();

    BEGIN
        WHILE v_current_date_time::date <= p_end_date LOOP
            v_date_message := 'Processing '
                || SUBSTRING(to_char(v_current_date_time::date, 'Day'), 1, 3)
                || ' '
                || to_char(v_current_date_time::date, 'Mon DD, YYYY')
                || ' '
                || CAST((p_end_date - v_current_date_time::date) AS varchar)
                || ' Days Remaining';

            IF p_are_dates_printed OR NOT p_is_silent_mode THEN
                RAISE NOTICE '%', v_date_message;
            END IF;

            -- compute number of orders for this day
            v_current_year   := EXTRACT(YEAR FROM v_current_date_time)::integer;
            v_current_season := CEILING(EXTRACT(MONTH FROM v_current_date_time)::double precision / 3)::smallint;

            SELECT "SeasonalVariation", "YearlyVariation"
            INTO v_seasonal_variation, v_yearly_variation
            FROM dataloadsimulation.seasonvariation
            WHERE "Year" = v_current_year AND "Season" = v_current_season;

            v_x := CAST((v_current_date_time::date
                         - make_date(v_current_year, (v_current_season * 3) - 2, 1)) AS double precision) / 90.0;
            IF v_x > 1.0 THEN
                v_x := 1.0;
            END IF;

            v_season_effect  := (SIN(2.0 * 3.1415926 * (v_x - 0.25)) + 1.0) / 2.0;
            v_season_effect  := (v_seasonal_variation - 1.0) * v_season_effect + 1.0;

            v_yearly_effect  := 1.0 + (v_yearly_variation - 1.0)
                * CAST((v_current_date_time::date - make_date(v_current_year - 1, 12, 31)) AS double precision) / 183.0;

            v_daily_effect   := random();
            IF v_daily_effect < 0.5 THEN
                v_daily_effect := 0.0 - v_daily_effect;
            END IF;
            v_daily_effect   := 1.0 + v_daily_effect * (p_max_daily_variation_percent::double precision / 100.0);

            v_number_of_customer_orders := (v_old_number_of_customer_orders
                                            * v_daily_effect * v_season_effect * v_yearly_effect)::integer;

            -- day-of-week calculations (PostgreSQL DOW: 0=Sunday, 1=Monday, 6=Saturday)
            v_weekday    := EXTRACT(DOW FROM v_current_date_time)::integer;
            v_is_saturday := false;
            v_is_sunday   := false;
            v_is_monday   := false;
            v_is_weekday  := true;

            IF v_weekday = 6 THEN
                v_is_saturday := true;
                v_is_weekday  := false;
            END IF;
            IF v_weekday = 0 THEN
                v_is_sunday  := true;
                v_is_weekday := false;
            END IF;
            IF v_weekday = 1 THEN
                v_is_monday := true;
            END IF;

            -- Receive purchase orders (weekdays, 7 AM)
            IF v_is_weekday THEN
                IF NOT p_is_silent_mode THEN
                    RAISE NOTICE '% - Receiving Purchase Orders', v_date_message;
                END IF;
                v_starting_when := v_current_date_time + interval '7 hours';
                PERFORM dataloadsimulation.receive_purchase_orders(v_current_date_time, v_starting_when, v_end_of_time, p_is_silent_mode);
            END IF;

            -- Password changes (8 AM)
            IF NOT p_is_silent_mode THEN
                RAISE NOTICE '% - Changing Passwords', v_date_message;
            END IF;
            v_starting_when := v_current_date_time + interval '8 hours';
            PERFORM dataloadsimulation.change_passwords(v_current_date_time, v_starting_when, v_end_of_time, p_is_silent_mode);

            -- Activate new website users (8:10 AM)
            IF NOT p_is_silent_mode THEN
                RAISE NOTICE '% - Activating Website Logins', v_date_message;
            END IF;
            v_starting_when := v_current_date_time + interval '8 hours 10 minutes';
            PERFORM dataloadsimulation.activate_website_logons(v_current_date_time, v_starting_when, v_end_of_time, p_is_silent_mode);

            -- Pay suppliers on Mondays (9 AM)
            IF v_weekday = 1 THEN
                IF NOT p_is_silent_mode THEN
                    RAISE NOTICE '% - Paying Suppliers', v_date_message;
                END IF;
                v_starting_when := v_current_date_time + interval '9 hours';
                PERFORM dataloadsimulation.pay_suppliers(v_current_date_time, v_starting_when, v_end_of_time, p_is_silent_mode);
            END IF;

            -- Customer orders (10 AM), scaled by weekend percentage
            v_starting_when := v_current_date_time + interval '10 hours';
            v_number_of_customer_orders := CASE v_weekday
                WHEN 6 THEN FLOOR(v_number_of_customer_orders * p_saturday_percentage_of_normal_work_day / 100)
                WHEN 0 THEN FLOOR(v_number_of_customer_orders * p_sunday_percentage_of_normal_work_day / 100)
                ELSE v_number_of_customer_orders
            END;

            IF NOT p_is_silent_mode THEN
                RAISE NOTICE '% - Creating Customer Orders', v_date_message;
            END IF;
            PERFORM dataloadsimulation.create_customer_orders(v_current_date_time, v_starting_when, v_end_of_time, v_number_of_customer_orders, p_is_silent_mode);

            -- Pick stock (11 AM)
            IF NOT p_is_silent_mode THEN
                RAISE NOTICE '% - Picking Stock for Customer Orders', v_date_message;
            END IF;
            v_starting_when := v_current_date_time + interval '11 hours';
            PERFORM dataloadsimulation.pick_stock_for_customer_orders(v_current_date_time, v_starting_when, v_end_of_time, p_is_silent_mode);

            -- Process customer payments on weekdays (11:30 AM)
            IF v_is_weekday THEN
                IF NOT p_is_silent_mode THEN
                    RAISE NOTICE '% - Processing Customer Payments', v_date_message;
                END IF;
                v_starting_when := v_current_date_time + interval '11 hours 30 minutes';
                PERFORM dataloadsimulation.process_customer_payments(v_current_date_time, v_starting_when, v_end_of_time, p_is_silent_mode);
            END IF;

            -- Invoice picked orders (noon)
            IF NOT p_is_silent_mode THEN
                RAISE NOTICE '% - Invoicing Picked Orders', v_date_message;
            END IF;
            v_starting_when := v_current_date_time + interval '12 hours';
            PERFORM dataloadsimulation.invoice_picked_orders(v_current_date_time, v_starting_when, v_end_of_time, p_is_silent_mode);

            -- Place supplier orders on weekdays (1 PM)
            IF v_is_weekday THEN
                IF NOT p_is_silent_mode THEN
                    RAISE NOTICE '% - Placing Supplier Orders', v_date_message;
                END IF;
                v_starting_when := v_current_date_time + interval '13 hours';
                PERFORM dataloadsimulation.place_supplier_orders(v_current_date_time, v_starting_when, v_end_of_time, p_is_silent_mode);
            END IF;

            -- End-of-quarter stocktake (Jan 31, Apr 30, Jul 31, Oct 31 at 2 PM)
            IF     (EXTRACT(MONTH FROM v_current_date_time)::integer =  1 AND EXTRACT(DAY FROM v_current_date_time)::integer = 31)
                OR (EXTRACT(MONTH FROM v_current_date_time)::integer =  4 AND EXTRACT(DAY FROM v_current_date_time)::integer = 30)
                OR (EXTRACT(MONTH FROM v_current_date_time)::integer =  7 AND EXTRACT(DAY FROM v_current_date_time)::integer = 31)
                OR (EXTRACT(MONTH FROM v_current_date_time)::integer = 10 AND EXTRACT(DAY FROM v_current_date_time)::integer = 31)
            THEN
                IF NOT p_is_silent_mode THEN
                    RAISE NOTICE '% - Performing Stock Take', v_date_message;
                END IF;
                v_starting_when := v_current_date_time + interval '14 hours';
                PERFORM dataloadsimulation.perform_stocktake(v_current_date_time, v_starting_when, v_end_of_time, p_is_silent_mode);
            END IF;

            -- Record invoice deliveries (7 AM)
            IF NOT p_is_silent_mode THEN
                RAISE NOTICE '% - Recording Invoice Deliveries', v_date_message;
            END IF;
            v_starting_when := v_current_date_time + interval '7 hours';
            PERFORM dataloadsimulation.record_invoice_deliveries(v_current_date_time, v_starting_when, v_end_of_time, p_is_silent_mode);

            -- Add new customers on weekdays (3 PM)
            IF v_is_weekday THEN
                IF NOT p_is_silent_mode THEN
                    RAISE NOTICE '% - Adding Customers', v_date_message;
                END IF;
                v_starting_when := v_current_date_time + interval '15 hours';
                PERFORM dataloadsimulation.add_customers(v_current_date_time, v_starting_when, v_end_of_time, p_is_silent_mode);
            END IF;

            -- Add stock items (4 PM)
            IF NOT p_is_silent_mode THEN
                RAISE NOTICE '% - Adding Stock Items', v_date_message;
            END IF;
            v_starting_when := v_current_date_time + interval '16 hours';
            PERFORM dataloadsimulation.add_stock_items(v_current_date_time, v_starting_when, v_end_of_time, p_is_silent_mode);

            -- Add special deals (4 PM)
            IF NOT p_is_silent_mode THEN
                RAISE NOTICE '% - Adding Special Deals', v_date_message;
            END IF;
            PERFORM dataloadsimulation.add_special_deals(v_current_date_time, v_starting_when, v_end_of_time, p_is_silent_mode);

            -- Temporal changes (4 PM)
            IF NOT p_is_silent_mode THEN
                RAISE NOTICE '% - Making Temporal Changes', v_date_message;
            END IF;
            PERFORM dataloadsimulation.make_temporal_changes(v_current_date_time, v_starting_when, v_end_of_time, p_is_silent_mode);

            -- Delivery van temperatures from 2022-01-01 onward (7 AM)
            IF v_current_date_time >= '2022-01-01'::timestamp THEN
                IF NOT p_is_silent_mode THEN
                    RAISE NOTICE '% - Recording Delivery Van Temperatures', v_date_message;
                END IF;
                v_starting_when := v_current_date_time + interval '7 hours';
                PERFORM dataloadsimulation.record_delivery_van_temperatures(300, 2, v_current_date_time, v_starting_when, p_is_silent_mode);
            END IF;

            -- Cold room temperatures from 2021-12-20 onward
            IF v_current_date_time >= '2021-12-20'::timestamp THEN
                IF NOT p_is_silent_mode THEN
                    RAISE NOTICE '% - Recording Cold Room Temperatures', v_date_message;
                END IF;
                PERFORM dataloadsimulation.record_cold_room_temperatures(3600, 40, v_current_date_time, v_end_of_time, p_is_silent_mode);
            END IF;

            v_current_date_time := v_current_date_time + interval '1 day';

            -- when rolling over to a new year, re-baseline the order count
            IF EXTRACT(DAY FROM v_current_date_time)::integer = 1
               AND EXTRACT(MONTH FROM v_current_date_time)::integer = 1 THEN
                v_old_number_of_customer_orders := (v_old_number_of_customer_orders * v_yearly_effect)::integer;
            END IF;
        END LOOP;

        IF NOT p_is_silent_mode THEN
            RAISE NOTICE 'Updating Custom Fields';
        END IF;
        IF p_update_custom_fields THEN
            PERFORM dataloadsimulation.update_custom_fields(p_end_date);
        END IF;

        IF NOT p_is_silent_mode THEN
            RAISE NOTICE 'Reactivating Temporal Tables After Data Load';
        END IF;
        PERFORM dataloadsimulation.reactivate_temporal_tables_after_data_load();

        IF NOT p_is_silent_mode THEN
            RAISE NOTICE 'Reseeding All Sequences';
        END IF;
        PERFORM sequences.reseed_all_sequences();

        IF NOT p_is_silent_mode THEN
            RAISE NOTICE 'Applying Row Level Security';
        END IF;
        PERFORM application.configuration_apply_row_level_security();

        IF NOT p_is_silent_mode THEN
            RAISE NOTICE 'Done Creating Wide World Importers Data History';
        END IF;

    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Error detected. Attempting cleanup before re-raising.';
        PERFORM dataloadsimulation.reactivate_temporal_tables_after_data_load();
        PERFORM sequences.reseed_all_sequences();
        PERFORM application.configuration_apply_row_level_security();
        RAISE;
    END;
END;
$$ LANGUAGE plpgsql;
