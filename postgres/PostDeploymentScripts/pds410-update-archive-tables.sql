-- NOTE: This script should be moved to MakeTemporalChanges procedure, but currently it doesn't work there.
-- @TODO: Investigate how to move it there.

\echo 'Updating StockItems history...'

SELECT dataloadsimulation.deactivate_temporal_tables_before_data_load();

UPDATE warehouse.stockitems_archive AS sa
SET UnitPrice              = s.UnitPrice              * (1 - .05 * ((NOW()::date - sa.ValidFrom::date) / 365.0)),
    RecommendedRetailPrice = s.RecommendedRetailPrice * (1 - .03 * ((NOW()::date - sa.ValidFrom::date) / 365.0)),
    TaxRate                = s.TaxRate                * (1 + .02 * ((NOW()::date - sa.ValidFrom::date) / 365.0)),
    QuantityPerOuter       = CEIL(s.QuantityPerOuter  * (1 + .05 * ((NOW()::date - sa.ValidFrom::date) / 365.0))),
    LeadTimeDays           = CEIL(s.LeadTimeDays      * (1 + .03 * ((NOW()::date - sa.ValidFrom::date) / 365.0))),
    TypicalWeightPerUnit   = CEIL(s.TypicalWeightPerUnit * (1 + .02 * ((NOW()::date - sa.ValidFrom::date) / 365.0)))
FROM warehouse.stockitems s
WHERE sa.StockItemID = s.StockItemID;

SELECT dataloadsimulation.reactivate_temporal_tables_after_data_load();
