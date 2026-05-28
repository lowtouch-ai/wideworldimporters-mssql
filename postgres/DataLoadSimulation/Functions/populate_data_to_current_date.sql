-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/PopulateDataToCurrentDate.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.populate_data_to_current_date(
    p_average_number_of_customer_orders_per_day integer,
    p_saturday_percentage_of_normal_work_day    integer,
    p_sunday_percentage_of_normal_work_day      integer,
    p_is_silent_mode                            boolean,
    p_are_dates_printed                         boolean
) RETURNS void AS $$
DECLARE
    v_current_maximum_date date;
    v_starting_date        date;
    v_ending_date          date;
BEGIN
    SELECT COALESCE(MAX("OrderDate"), '2019-12-31') INTO v_current_maximum_date
    FROM sales.orders;

    v_starting_date := v_current_maximum_date + 1;
    v_ending_date   := CAST(CURRENT_TIMESTAMP AS date) - 1;

    PERFORM dataloadsimulation.daily_process_to_create_history(
        p_start_date                             => v_starting_date,
        p_end_date                               => v_ending_date,
        p_average_number_of_customer_orders_per_day => p_average_number_of_customer_orders_per_day,
        p_saturday_percentage_of_normal_work_day => p_saturday_percentage_of_normal_work_day,
        p_sunday_percentage_of_normal_work_day   => p_sunday_percentage_of_normal_work_day,
        p_update_custom_fields                   => false,
        p_is_silent_mode                         => p_is_silent_mode,
        p_are_dates_printed                      => p_are_dates_printed
    );
END;
$$ LANGUAGE plpgsql;
