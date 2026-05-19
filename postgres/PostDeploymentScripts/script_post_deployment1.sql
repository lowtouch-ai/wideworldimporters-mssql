-- Post-Deployment Script for WideWorldImporters PostgreSQL
-- Run via: psql -U postgres -d wideworldimporters -f script_post_deployment1.sql
-- Prerequisites: PostGIS extension, all schema DDL deployed, all functions deployed

-- Apply full-text indexing configuration
SELECT application.configuration_apply_full_text_indexing();

-- Deactivate temporal tables before data load
SELECT dataloadsimulation.deactivate_temporal_tables_before_data_load();

-- Note: DataLoadSimulation stored procedures are already deployed as PG functions.
-- (UpdateCustomFields, RecordColdRoomTemperatures, MakeTemporalChanges,
--  ChangePasswords, AddStockItems, AddCustomers, ActivateWebsiteLogons)

-- Load reference / lookup data
\i pds100-ins-app-people.sql
\i pds105-ins-dls-ficticiousnamepool.sql
\i pds106-ins-dls-areacode.sql
\i pds110-ins-app-countries.sql
\i pds120-ins-app-deliverymethods.sql
\i pds130-ins-app-paymentmethods.sql
\i pds140-ins-app-stateprovinces.sql
\i pds142-upd-app-stateprovinces-borders.sql

-- Load a subset of cities (sufficient for most demos)
\i pds150-ins-app-cities.sql

-- Optional: load the full city list by letter.
-- These are commented out by default (same as the original SSDT deployment).
-- Uncomment to load all ~38K additional cities.
--\i pds150-ins-app-cities-a.sql
--\i pds150-ins-app-cities-b.sql
--\i pds150-ins-app-cities-c.sql
--\i pds150-ins-app-cities-d.sql
--\i pds150-ins-app-cities-e.sql
--\i pds150-ins-app-cities-f.sql
--\i pds150-ins-app-cities-g.sql
--\i pds150-ins-app-cities-h.sql
--\i pds150-ins-app-cities-i.sql
--\i pds150-ins-app-cities-j.sql
--\i pds150-ins-app-cities-k.sql
--\i pds150-ins-app-cities-l.sql
--\i pds150-ins-app-cities-m.sql
--\i pds150-ins-app-cities-n.sql
--\i pds150-ins-app-cities-o.sql
--\i pds150-ins-app-cities-p.sql
--\i pds150-ins-app-cities-q.sql
--\i pds150-ins-app-cities-r.sql
--\i pds150-ins-app-cities-s.sql
--\i pds150-ins-app-cities-t.sql
--\i pds150-ins-app-cities-u.sql
--\i pds150-ins-app-cities-v.sql
--\i pds150-ins-app-cities-w.sql
--\i pds150-ins-app-cities-x.sql
--\i pds150-ins-app-cities-y.sql
--\i pds150-ins-app-cities-z.sql

\i pds151-ins-post-app-cities.sql
\i pds160-ins-app-transactiontypes.sql
\i pds170-ins-purchasing-suppliercategories.sql
\i pds180-ins-sales-groups-categories.sql
\i pds190-ins-warehouse-colors.sql
\i pds200-ins-warehouse-packagetypes.sql
\i pds210-ins-warehouse-stockgroups.sql
\i pds220-ins-purchasing-suppliers.sql
\i pds230-ins-sales-customers.sql
\i pds240-ins-warehouse-stockitems.sql
\i pds250-ins-warehouse-stockitemholdings.sql
\i pds260-ins-warehouse-stockitemstockgroups.sql
\i pds270-ins-app-systemparameters.sql

\echo 'Data Load Simulation: Reactivate Temporal Tables after Data Load'
SELECT dataloadsimulation.reactivate_temporal_tables_after_data_load();

\echo 'Reseed All Sequences'
SELECT sequences.reseed_all_sequences();

\echo 'Populating limited data set.'

SELECT dataloadsimulation.daily_process_to_create_history(
    p_start_date                                 => '20200101',
    p_end_date                                   => '20200201',
    p_average_number_of_customer_orders_per_day  => 30,
    p_saturday_percentage_of_normal_work_day     => 25,
    p_sunday_percentage_of_normal_work_day       => 0,
    p_update_custom_fields                       => true,
    p_is_silent_mode                             => false,
    p_are_dates_printed                          => true
);

\i pds400-ins-unkown-orderline.sql
\i pds410-update-archive-tables.sql
