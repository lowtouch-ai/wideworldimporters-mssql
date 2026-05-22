-- Converted from: wwi-ssdt/wwi-ssdt/Sequences/Stored Procedures/ReseedAllSequences.sql
CREATE SCHEMA IF NOT EXISTS sequences;

CREATE OR REPLACE FUNCTION sequences.reseed_all_sequences() RETURNS void AS $$
BEGIN
    PERFORM sequences.reseed_sequence_beyond_table_values('buying_group_id_seq',          'sales',        'buying_groups',          'BuyingGroupID');
    PERFORM sequences.reseed_sequence_beyond_table_values('city_id_seq',                  'application',  'cities',                 'CityID');
    PERFORM sequences.reseed_sequence_beyond_table_values('color_id_seq',                 'warehouse',    'colors',                 'ColorID');
    PERFORM sequences.reseed_sequence_beyond_table_values('country_id_seq',               'application',  'countries',              'CountryID');
    PERFORM sequences.reseed_sequence_beyond_table_values('customer_category_id_seq',     'sales',        'customer_categories',    'CustomerCategoryID');
    PERFORM sequences.reseed_sequence_beyond_table_values('customer_id_seq',              'sales',        'customers',              'CustomerID');
    PERFORM sequences.reseed_sequence_beyond_table_values('delivery_method_id_seq',       'application',  'delivery_methods',       'DeliveryMethodID');
    PERFORM sequences.reseed_sequence_beyond_table_values('invoice_id_seq',               'sales',        'invoices',               'InvoiceID');
    PERFORM sequences.reseed_sequence_beyond_table_values('invoice_line_id_seq',          'sales',        'invoicelines',           'InvoiceLineID');
    PERFORM sequences.reseed_sequence_beyond_table_values('order_id_seq',                 'sales',        'orders',                 'OrderID');
    PERFORM sequences.reseed_sequence_beyond_table_values('order_line_id_seq',            'sales',        'orderlines',             'OrderLineID');
    PERFORM sequences.reseed_sequence_beyond_table_values('package_type_id_seq',          'warehouse',    'package_types',          'PackageTypeID');
    PERFORM sequences.reseed_sequence_beyond_table_values('payment_method_id_seq',        'application',  'payment_methods',        'PaymentMethodID');
    PERFORM sequences.reseed_sequence_beyond_table_values('person_id_seq',                'application',  'people',                 'PersonID');
    PERFORM sequences.reseed_sequence_beyond_table_values('purchase_order_id_seq',        'purchasing',   'purchaseorders',         'PurchaseOrderID');
    PERFORM sequences.reseed_sequence_beyond_table_values('purchase_order_line_id_seq',   'purchasing',   'purchaseorderlines',     'PurchaseOrderLineID');
    PERFORM sequences.reseed_sequence_beyond_table_values('special_deal_id_seq',          'sales',        'specialdeals',           'SpecialDealID');
    PERFORM sequences.reseed_sequence_beyond_table_values('state_province_id_seq',        'application',  'state_provinces',        'StateProvinceID');
    PERFORM sequences.reseed_sequence_beyond_table_values('stock_group_id_seq',           'warehouse',    'stock_groups',           'StockGroupID');
    PERFORM sequences.reseed_sequence_beyond_table_values('stock_item_id_seq',            'warehouse',    'stockitems',             'StockItemID');
    PERFORM sequences.reseed_sequence_beyond_table_values('stock_item_stock_group_id_seq','warehouse',    'stockitemstockgroups',   'StockItemStockGroupID');
    PERFORM sequences.reseed_sequence_beyond_table_values('supplier_category_id_seq',     'purchasing',   'supplier_categories',    'SupplierCategoryID');
    PERFORM sequences.reseed_sequence_beyond_table_values('supplier_id_seq',              'purchasing',   'suppliers',              'SupplierID');
    PERFORM sequences.reseed_sequence_beyond_table_values('system_parameter_id_seq',      'application',  'system_parameters',      'SystemParameterID');
    PERFORM sequences.reseed_sequence_beyond_table_values('transaction_id_seq',           'purchasing',   'suppliertransactions',   'SupplierTransactionID');
    PERFORM sequences.reseed_sequence_beyond_table_values('transaction_id_seq',           'sales',        'customertransactions',   'CustomerTransactionID');
    PERFORM sequences.reseed_sequence_beyond_table_values('transaction_id_seq',           'warehouse',    'stockitemtransactions',  'StockItemTransactionID');
    PERFORM sequences.reseed_sequence_beyond_table_values('transaction_type_id_seq',      'application',  'transaction_types',      'TransactionTypeID');
END;
$$ LANGUAGE plpgsql;
