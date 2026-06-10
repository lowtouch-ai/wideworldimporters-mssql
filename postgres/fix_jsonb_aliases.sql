-- Fix: quote PascalCase column aliases and references in jsonb_to_record / jsonb_to_recordset
-- blocks across all 36 webapi insert_* and update_* functions.
--
-- Root cause: PostgreSQL folds unquoted identifiers to lowercase, so aliases like
-- TransactionTypeName inside AS json(...) became transactiontypename, which did not
-- match the PascalCase JSON keys sent by the app — causing NULL writes and NOT NULL violations.
--
-- Applied to: 15 insert_* functions + 21 update_* functions (36 total)
-- NOTE: For insert_* functions the array-wrap fix in fix_insert_funcs.sql supersedes this file.

CREATE OR REPLACE FUNCTION webapi.insert_buying_groups_from_json(p_buying_groups text, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    INSERT INTO sales.buyinggroups (BuyingGroupName, LastEditedBy)
    SELECT x."BuyingGroupName", p_user_id
    FROM jsonb_to_recordset(p_buying_groups::jsonb) AS x("BuyingGroupName" varchar(50));
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.insert_cities_from_json(p_cities text, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    INSERT INTO application.cities (CityName, StateProvinceID, LatestRecordedPopulation, LastEditedBy)
    SELECT x."CityName", x."StateProvinceID", x."LatestRecordedPopulation", p_user_id
    FROM jsonb_to_recordset(p_cities::jsonb) AS x(
        "CityName" varchar(50),
        "StateProvinceID" integer,
        "LatestRecordedPopulation" bigint
    );
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.insert_colors_from_json(p_colors text, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    INSERT INTO warehouse.colors (ColorName, LastEditedBy)
    SELECT x."ColorName", p_user_id
    FROM jsonb_to_recordset(p_colors::jsonb) AS x("ColorName" varchar(50));
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.insert_countries_from_json(p_countries text, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    INSERT INTO application.countries (
        CountryName, FormalName, IsoAlpha3Code, IsoNumericCode, CountryType,
        LatestRecordedPopulation, Continent, Region, Subregion, LastEditedBy
    )
    SELECT
        x."CountryName", x."FormalName", x."IsoAlpha3Code", x."IsoNumericCode", x."CountryType",
        x."LatestRecordedPopulation", x."Continent", x."Region", x."Subregion", p_user_id
    FROM jsonb_to_recordset(p_countries::jsonb) AS x(
        "CountryName" varchar(60),
        "FormalName" varchar(60),
        "IsoAlpha3Code" varchar(3),
        "IsoNumericCode" integer,
        "CountryType" varchar(20),
        "LatestRecordedPopulation" bigint,
        "Continent" varchar(30),
        "Region" varchar(30),
        "Subregion" varchar(30)
    );
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.insert_customer_categories_from_json(p_customer_categories text, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    INSERT INTO sales.customercategories (CustomerCategoryName, LastEditedBy)
    SELECT x."CustomerCategoryName", p_user_id
    FROM jsonb_to_recordset(p_customer_categories::jsonb) AS x("CustomerCategoryName" varchar(50));
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.insert_customers_from_json(p_customers text, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    INSERT INTO sales.customers (
        CustomerName, BillToCustomerID, CustomerCategoryID, BuyingGroupID,
        PrimaryContactPersonID, AlternateContactPersonID, DeliveryMethodID,
        DeliveryCityID, PostalCityID, CreditLimit, AccountOpenedDate,
        StandardDiscountPercentage, IsStatementSent, IsOnCreditHold,
        PaymentDays, PhoneNumber, FaxNumber, DeliveryRun, RunPosition,
        WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode,
        PostalAddressLine1, PostalAddressLine2, PostalPostalCode, LastEditedBy
    )
    SELECT
        x."CustomerName", x."BillToCustomerID", x."CustomerCategoryID", x."BuyingGroupID",
        x."PrimaryContactPersonID", x."AlternateContactPersonID", x."DeliveryMethodID",
        x."DeliveryCityID", x."PostalCityID", x."CreditLimit", x."AccountOpenedDate",
        x."StandardDiscountPercentage", x."IsStatementSent", x."IsOnCreditHold",
        x."PaymentDays", x."PhoneNumber", x."FaxNumber", x."DeliveryRun", x."RunPosition",
        x."WebsiteURL", x."DeliveryAddressLine1", x."DeliveryAddressLine2", x."DeliveryPostalCode",
        x."PostalAddressLine1", x."PostalAddressLine2", x."PostalPostalCode", p_user_id
    FROM jsonb_to_recordset(p_customers::jsonb) AS x(
        "CustomerName" varchar(100),
        "BillToCustomerID" integer,
        "CustomerCategoryID" integer,
        "BuyingGroupID" integer,
        "PrimaryContactPersonID" integer,
        "AlternateContactPersonID" integer,
        "DeliveryMethodID" integer,
        "DeliveryCityID" integer,
        "PostalCityID" integer,
        "CreditLimit" numeric(18,2),
        "AccountOpenedDate" date,
        "StandardDiscountPercentage" numeric(18,3),
        "IsStatementSent" boolean,
        "IsOnCreditHold" boolean,
        "PaymentDays" integer,
        "PhoneNumber" varchar(20),
        "FaxNumber" varchar(20),
        "DeliveryRun" varchar(5),
        "RunPosition" varchar(5),
        "WebsiteURL" varchar(256),
        "DeliveryAddressLine1" varchar(60),
        "DeliveryAddressLine2" varchar(60),
        "DeliveryPostalCode" varchar(10),
        "PostalAddressLine1" varchar(60),
        "PostalAddressLine2" varchar(60),
        "PostalPostalCode" varchar(10)
    );
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.insert_delivery_methods_from_json(p_delivery_methods text, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    INSERT INTO application.deliverymethods (DeliveryMethodName, LastEditedBy)
    SELECT x."DeliveryMethodName", p_user_id
    FROM jsonb_to_recordset(p_delivery_methods::jsonb) AS x("DeliveryMethodName" varchar(50));
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.insert_package_types_from_json(p_package_types text, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    INSERT INTO warehouse.packagetypes (PackageTypeName, LastEditedBy)
    SELECT x."PackageTypeName", p_user_id
    FROM jsonb_to_recordset(p_package_types::jsonb) AS x("PackageTypeName" varchar(50));
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.insert_payment_methods_from_json(p_payment_methods text, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    INSERT INTO application.paymentmethods (PaymentMethodName, LastEditedBy)
    SELECT x."PaymentMethodName", p_user_id
    FROM jsonb_to_recordset(p_payment_methods::jsonb) AS x("PaymentMethodName" varchar(50));
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.insert_state_provinces_from_json(p_state_provinces text, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    INSERT INTO application.stateprovinces (
        StateProvinceCode, StateProvinceName, CountryID,
        SalesTerritory, LatestRecordedPopulation, LastEditedBy
    )
    SELECT x."StateProvinceCode", x."StateProvinceName", x."CountryID",
           x."SalesTerritory", x."LatestRecordedPopulation", p_user_id
    FROM jsonb_to_recordset(p_state_provinces::jsonb) AS x(
        "StateProvinceCode" varchar(5),
        "StateProvinceName" varchar(50),
        "CountryID" integer,
        "SalesTerritory" varchar(50),
        "LatestRecordedPopulation" bigint
    );
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.insert_stock_groups_from_json(p_stock_groups text, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    INSERT INTO warehouse.stockgroups (StockGroupName, LastEditedBy)
    SELECT x."StockGroupName", p_user_id
    FROM jsonb_to_recordset(p_stock_groups::jsonb) AS x("StockGroupName" varchar(50));
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.insert_stock_items_from_json(p_stock_items text, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    INSERT INTO warehouse.stockitems (
        StockItemName, SupplierID, ColorID, UnitPackageID, OuterPackageID,
        Brand, Size, LeadTimeDays, QuantityPerOuter, IsChillerStock,
        Barcode, TaxRate, UnitPrice, RecommendedRetailPrice, TypicalWeightPerUnit,
        MarketingComments, InternalComments, Photo, CustomFields, LastEditedBy
    )
    SELECT
        x."StockItemName", x."SupplierID", x."ColorID", x."UnitPackageID", x."OuterPackageID",
        x."Brand", x."Size", x."LeadTimeDays", x."QuantityPerOuter", x."IsChillerStock",
        x."Barcode", x."TaxRate", x."UnitPrice", x."RecommendedRetailPrice", x."TypicalWeightPerUnit",
        x."MarketingComments", x."InternalComments", x."Photo", x."CustomFields", p_user_id
    FROM jsonb_to_recordset(p_stock_items::jsonb) AS x(
        "StockItemName" varchar(100),
        "SupplierID" integer,
        "ColorID" integer,
        "UnitPackageID" integer,
        "OuterPackageID" integer,
        "Brand" varchar(50),
        "Size" varchar(20),
        "LeadTimeDays" integer,
        "QuantityPerOuter" integer,
        "IsChillerStock" boolean,
        "Barcode" varchar(50),
        "TaxRate" numeric(18,3),
        "UnitPrice" numeric(18,2),
        "RecommendedRetailPrice" numeric(18,2),
        "TypicalWeightPerUnit" numeric(18,3),
        "MarketingComments" text,
        "InternalComments" text,
        "Photo" bytea,
        "CustomFields" jsonb
    );
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.insert_supplier_categories_from_json(p_supplier_categories text, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    INSERT INTO purchasing.suppliercategories (SupplierCategoryName, LastEditedBy)
    SELECT x."SupplierCategoryName", p_user_id
    FROM jsonb_to_recordset(p_supplier_categories::jsonb) AS x("SupplierCategoryName" varchar(50));
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.insert_suppliers_from_json(p_suppliers text, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    INSERT INTO purchasing.suppliers (
        SupplierName, SupplierCategoryID, PrimaryContactPersonID, AlternateContactPersonID,
        DeliveryMethodID, DeliveryCityID, PostalCityID, SupplierReference,
        BankAccountName, BankAccountBranch, BankAccountCode, BankAccountNumber,
        BankInternationalCode, PaymentDays, InternalComments, PhoneNumber,
        FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2,
        DeliveryPostalCode, PostalAddressLine1, PostalAddressLine2, PostalPostalCode,
        LastEditedBy
    )
    SELECT
        x."SupplierName", x."SupplierCategoryID", x."PrimaryContactPersonID", x."AlternateContactPersonID",
        x."DeliveryMethodID", x."DeliveryCityID", x."PostalCityID", x."SupplierReference",
        x."BankAccountName", x."BankAccountBranch", x."BankAccountCode", x."BankAccountNumber",
        x."BankInternationalCode", x."PaymentDays", x."InternalComments", x."PhoneNumber",
        x."FaxNumber", x."WebsiteURL", x."DeliveryAddressLine1", x."DeliveryAddressLine2",
        x."DeliveryPostalCode", x."PostalAddressLine1", x."PostalAddressLine2", x."PostalPostalCode",
        p_user_id
    FROM jsonb_to_recordset(p_suppliers::jsonb) AS x(
        "SupplierName" varchar(100),
        "SupplierCategoryID" integer,
        "PrimaryContactPersonID" integer,
        "AlternateContactPersonID" integer,
        "DeliveryMethodID" integer,
        "DeliveryCityID" integer,
        "PostalCityID" integer,
        "SupplierReference" varchar(20),
        "BankAccountName" varchar(50),
        "BankAccountBranch" varchar(50),
        "BankAccountCode" varchar(20),
        "BankAccountNumber" varchar(20),
        "BankInternationalCode" varchar(20),
        "PaymentDays" integer,
        "InternalComments" text,
        "PhoneNumber" varchar(20),
        "FaxNumber" varchar(20),
        "WebsiteURL" varchar(256),
        "DeliveryAddressLine1" varchar(60),
        "DeliveryAddressLine2" varchar(60),
        "DeliveryPostalCode" varchar(10),
        "PostalAddressLine1" varchar(60),
        "PostalAddressLine2" varchar(60),
        "PostalPostalCode" varchar(10)
    );
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.insert_transaction_types_from_json(p_transaction_types text, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    INSERT INTO application.transactiontypes (TransactionTypeName, LastEditedBy)
    SELECT x."TransactionTypeName", p_user_id
    FROM jsonb_to_recordset(p_transaction_types::jsonb) AS x("TransactionTypeName" varchar(50));
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.update_buying_group_from_json(p_buying_group text, p_buying_group_id integer, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE sales.buyinggroups SET
        BuyingGroupName = json."BuyingGroupName",
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_buying_group::jsonb) AS json("BuyingGroupName" varchar(50))
    WHERE BuyingGroupID = p_buying_group_id;
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.update_city_from_json(p_city text, p_city_id integer, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE application.cities SET
        CityName = json."CityName",
        StateProvinceID = json."StateProvinceID",
        LatestRecordedPopulation = json."LatestRecordedPopulation",
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_city::jsonb) AS json(
        "CityName" varchar(50),
        "StateProvinceID" integer,
        "LatestRecordedPopulation" bigint
    )
    WHERE CityID = p_city_id;
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.update_color_from_json(p_color text, p_color_id integer, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE warehouse.colors SET
        ColorName = json."ColorName",
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_color::jsonb) AS json("ColorName" varchar(50))
    WHERE ColorID = p_color_id;
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.update_country_from_json(p_country text, p_country_id integer, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE application.countries SET
        CountryName = json."CountryName",
        FormalName = json."FormalName",
        IsoAlpha3Code = json."IsoAlpha3Code",
        IsoNumericCode = json."IsoNumericCode",
        CountryType = json."CountryType",
        LatestRecordedPopulation = json."LatestRecordedPopulation",
        Continent = json."Continent",
        Region = json."Region",
        Subregion = json."Subregion",
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_country::jsonb) AS json(
        "CountryName" varchar(60),
        "FormalName" varchar(60),
        "IsoAlpha3Code" varchar(3),
        "IsoNumericCode" integer,
        "CountryType" varchar(20),
        "LatestRecordedPopulation" bigint,
        "Continent" varchar(30),
        "Region" varchar(30),
        "Subregion" varchar(30)
    )
    WHERE CountryID = p_country_id;
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.update_customer_category_from_json(p_customer_category text, p_customer_category_id integer, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE sales.customercategories SET
        CustomerCategoryName = json."CustomerCategoryName",
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_customer_category::jsonb) AS json("CustomerCategoryName" varchar(50))
    WHERE CustomerCategoryID = p_customer_category_id;
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.update_customer_from_json(p_customer text, p_customer_id integer, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE sales.customers SET
        CustomerName = COALESCE(json."CustomerName", sales.customers.CustomerName),
        BillToCustomerID = COALESCE(json."BillToCustomerID", sales.customers.BillToCustomerID),
        CustomerCategoryID = COALESCE(json."CustomerCategoryID", sales.customers.CustomerCategoryID),
        BuyingGroupID = json."BuyingGroupID",
        PrimaryContactPersonID = COALESCE(json."PrimaryContactPersonID", sales.customers.PrimaryContactPersonID),
        AlternateContactPersonID = COALESCE(json."AlternateContactPersonID", sales.customers.AlternateContactPersonID),
        DeliveryMethodID = COALESCE(json."DeliveryMethodID", sales.customers.DeliveryMethodID),
        DeliveryCityID = COALESCE(json."DeliveryCityID", sales.customers.DeliveryCityID),
        PostalCityID = COALESCE(json."PostalCityID", sales.customers.PostalCityID),
        CreditLimit = json."CreditLimit",
        AccountOpenedDate = COALESCE(json."AccountOpenedDate", sales.customers.AccountOpenedDate),
        StandardDiscountPercentage = COALESCE(json."StandardDiscountPercentage", sales.customers.StandardDiscountPercentage),
        IsStatementSent = COALESCE(json."IsStatementSent", sales.customers.IsStatementSent),
        IsOnCreditHold = COALESCE(json."IsOnCreditHold", sales.customers.IsOnCreditHold),
        PaymentDays = COALESCE(json."PaymentDays", sales.customers.PaymentDays),
        PhoneNumber = COALESCE(json."PhoneNumber", sales.customers.PhoneNumber),
        FaxNumber = COALESCE(json."FaxNumber", sales.customers.FaxNumber),
        DeliveryRun = json."DeliveryRun",
        RunPosition = json."RunPosition",
        WebsiteURL = COALESCE(json."WebsiteURL", sales.customers.WebsiteURL),
        DeliveryAddressLine1 = COALESCE(json."DeliveryAddressLine1", sales.customers.DeliveryAddressLine1),
        DeliveryAddressLine2 = json."DeliveryAddressLine2",
        DeliveryPostalCode = COALESCE(json."DeliveryPostalCode", sales.customers.DeliveryPostalCode),
        PostalAddressLine1 = COALESCE(json."PostalAddressLine1", sales.customers.PostalAddressLine1),
        PostalAddressLine2 = json."PostalAddressLine2",
        PostalPostalCode = COALESCE(json."PostalPostalCode", sales.customers.PostalPostalCode),
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_customer::jsonb) AS json(
        "CustomerName" varchar(100),
        "BillToCustomerID" integer,
        "CustomerCategoryID" integer,
        "BuyingGroupID" integer,
        "PrimaryContactPersonID" integer,
        "AlternateContactPersonID" integer,
        "DeliveryMethodID" integer,
        "DeliveryCityID" integer,
        "PostalCityID" integer,
        "CreditLimit" numeric(18,2),
        "AccountOpenedDate" date,
        "StandardDiscountPercentage" numeric(18,3),
        "IsStatementSent" boolean,
        "IsOnCreditHold" boolean,
        "PaymentDays" integer,
        "PhoneNumber" varchar(20),
        "FaxNumber" varchar(20),
        "DeliveryRun" varchar(5),
        "RunPosition" varchar(5),
        "WebsiteURL" varchar(256),
        "DeliveryAddressLine1" varchar(60),
        "DeliveryAddressLine2" varchar(60),
        "DeliveryPostalCode" varchar(10),
        "PostalAddressLine1" varchar(60),
        "PostalAddressLine2" varchar(60),
        "PostalPostalCode" varchar(10)
    )
    WHERE CustomerID = p_customer_id;
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.update_customer_transaction_from_json(p_customer_transaction text, p_customer_transaction_id integer, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE sales.customertransactions SET
        TransactionTypeID = COALESCE(json."TransactionTypeID", sales.customertransactions.TransactionTypeID),
        PaymentMethodID = json."PaymentMethodID",
        TransactionDate = COALESCE(json."TransactionDate", sales.customertransactions.TransactionDate),
        AmountExcludingTax = COALESCE(json."AmountExcludingTax", sales.customertransactions.AmountExcludingTax),
        TaxAmount = COALESCE(json."TaxAmount", sales.customertransactions.TaxAmount),
        TransactionAmount = COALESCE(json."TransactionAmount", sales.customertransactions.TransactionAmount),
        OutstandingBalance = COALESCE(json."OutstandingBalance", sales.customertransactions.OutstandingBalance),
        FinalizationDate = json."FinalizationDate",
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_customer_transaction::jsonb) AS json(
        "TransactionTypeID" integer,
        "PaymentMethodID" integer,
        "TransactionDate" date,
        "FinalizationDate" date,
        "AmountExcludingTax" numeric(18,2),
        "TaxAmount" numeric(18,2),
        "TransactionAmount" numeric(18,2),
        "OutstandingBalance" numeric(18,2)
    )
    WHERE CustomerTransactionID = p_customer_transaction_id;
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.update_delivery_method_from_json(p_delivery_method text, p_delivery_method_id integer, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE application.deliverymethods SET
        DeliveryMethodName = json."DeliveryMethodName",
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_delivery_method::jsonb) AS json("DeliveryMethodName" varchar(50))
    WHERE DeliveryMethodID = p_delivery_method_id;
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.update_invoice_from_json(p_invoice text, p_invoice_id integer, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE sales.invoices SET
        CustomerID = COALESCE(json."CustomerID", sales.invoices.CustomerID),
        BillToCustomerID = COALESCE(json."BillToCustomerID", sales.invoices.BillToCustomerID),
        DeliveryMethodID = COALESCE(json."DeliveryMethodID", sales.invoices.DeliveryMethodID),
        ContactPersonID = COALESCE(json."ContactPersonID", sales.invoices.ContactPersonID),
        AccountsPersonID = COALESCE(json."AccountsPersonID", sales.invoices.AccountsPersonID),
        SalespersonPersonID = COALESCE(json."SalespersonPersonID", sales.invoices.SalespersonPersonID),
        PackedByPersonID = COALESCE(json."PackedByPersonID", sales.invoices.PackedByPersonID),
        InvoiceDate = COALESCE(json."InvoiceDate", sales.invoices.InvoiceDate),
        CustomerPurchaseOrderNumber = json."CustomerPurchaseOrderNumber",
        IsCreditNote = COALESCE(json."IsCreditNote", sales.invoices.IsCreditNote),
        TotalDryItems = COALESCE(json."TotalDryItems", sales.invoices.TotalDryItems),
        TotalChillerItems = COALESCE(json."TotalChillerItems", sales.invoices.TotalChillerItems),
        DeliveryRun = json."DeliveryRun",
        RunPosition = json."RunPosition",
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_invoice::jsonb) AS json(
        "CustomerID" integer,
        "BillToCustomerID" integer,
        "OrderID" integer,
        "DeliveryMethodID" integer,
        "ContactPersonID" integer,
        "AccountsPersonID" integer,
        "SalespersonPersonID" integer,
        "PackedByPersonID" integer,
        "InvoiceDate" date,
        "CustomerPurchaseOrderNumber" varchar(20),
        "IsCreditNote" boolean,
        "TotalDryItems" integer,
        "TotalChillerItems" integer,
        "DeliveryRun" varchar(5),
        "RunPosition" varchar(5)
    )
    WHERE InvoiceID = p_invoice_id;
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.update_package_type_from_json(p_package_type text, p_package_type_id integer, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE warehouse.packagetypes SET
        PackageTypeName = json."PackageTypeName",
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_package_type::jsonb) AS json("PackageTypeName" varchar(50))
    WHERE PackageTypeID = p_package_type_id;
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.update_payment_method_from_json(p_payment_method text, p_payment_method_id integer, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE application.paymentmethods SET
        PaymentMethodName = json."PaymentMethodName",
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_payment_method::jsonb) AS json("PaymentMethodName" varchar(50))
    WHERE PaymentMethodID = p_payment_method_id;
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.update_purchase_order_from_json(p_purchase_order text, p_purchase_order_id integer, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE purchasing.purchaseorders SET
        SupplierID = COALESCE(json."SupplierID", purchasing.purchaseorders.SupplierID),
        OrderDate = COALESCE(json."OrderDate", purchasing.purchaseorders.OrderDate),
        DeliveryMethodID = COALESCE(json."DeliveryMethodID", purchasing.purchaseorders.DeliveryMethodID),
        ContactPersonID = COALESCE(json."ContactPersonID", purchasing.purchaseorders.ContactPersonID),
        ExpectedDeliveryDate = json."ExpectedDeliveryDate",
        SupplierReference = json."SupplierReference",
        IsOrderFinalized = COALESCE(json."IsOrderFinalized", purchasing.purchaseorders.IsOrderFinalized)
    FROM jsonb_to_record(p_purchase_order::jsonb) AS json(
        "SupplierID" integer,
        "OrderDate" date,
        "DeliveryMethodID" integer,
        "ContactPersonID" integer,
        "ExpectedDeliveryDate" date,
        "SupplierReference" varchar(20),
        "IsOrderFinalized" boolean
    )
    WHERE PurchaseOrderID = p_purchase_order_id;
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.update_sales_order_from_json(p_sales_order text, p_sales_order_id integer, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE sales.orders SET
        SalespersonPersonID = COALESCE(json."SalespersonPersonID", sales.orders.SalespersonPersonID),
        PickedByPersonID = COALESCE(json."PickedByPersonID", sales.orders.PickedByPersonID),
        ContactPersonID = COALESCE(json."ContactPersonID", sales.orders.ContactPersonID),
        BackorderOrderID = COALESCE(json."BackorderOrderID", sales.orders.BackorderOrderID),
        OrderDate = COALESCE(json."OrderDate", sales.orders.OrderDate),
        ExpectedDeliveryDate = COALESCE(json."ExpectedDeliveryDate", sales.orders.ExpectedDeliveryDate),
        CustomerPurchaseOrderNumber = COALESCE(json."CustomerPurchaseOrderNumber", sales.orders.CustomerPurchaseOrderNumber),
        IsUndersupplyBackordered = COALESCE(json."IsUndersupplyBackordered", sales.orders.IsUndersupplyBackordered),
        PickingCompletedWhen = COALESCE(json."PickingCompletedWhen", sales.orders.PickingCompletedWhen),
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_sales_order::jsonb) AS json(
        "SalespersonPersonID" integer,
        "PickedByPersonID" integer,
        "ContactPersonID" integer,
        "BackorderOrderID" integer,
        "OrderDate" date,
        "ExpectedDeliveryDate" date,
        "CustomerPurchaseOrderNumber" varchar(20),
        "IsUndersupplyBackordered" boolean,
        "PickingCompletedWhen" date
    )
    WHERE OrderID = p_sales_order_id;
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.update_special_deal_from_json(p_special_deal text, p_special_deal_id integer, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE sales.specialdeals SET
        StockItemID = json."StockItemID",
        CustomerID = json."CustomerID",
        BuyingGroupID = json."BuyingGroupID",
        CustomerCategoryID = json."CustomerCategoryID",
        StockGroupID = json."StockGroupID",
        DealDescription = COALESCE(json."DealDescription", sales.specialdeals.DealDescription),
        StartDate = COALESCE(json."StartDate", sales.specialdeals.StartDate),
        EndDate = COALESCE(json."EndDate", sales.specialdeals.EndDate),
        DiscountAmount = json."DiscountAmount",
        DiscountPercentage = json."DiscountPercentage",
        UnitPrice = json."UnitPrice",
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_special_deal::jsonb) AS json(
        "StockItemID" integer,
        "CustomerID" integer,
        "BuyingGroupID" integer,
        "CustomerCategoryID" integer,
        "StockGroupID" integer,
        "DealDescription" varchar(30),
        "StartDate" date,
        "EndDate" date,
        "DiscountAmount" numeric(18,2),
        "DiscountPercentage" numeric(18,3),
        "UnitPrice" numeric(18,2)
    )
    WHERE SpecialDealID = p_special_deal_id;
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.update_state_province_from_json(p_state_province text, p_state_province_id integer, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE application.stateprovinces SET
        StateProvinceCode = json."StateProvinceCode",
        StateProvinceName = json."StateProvinceName",
        CountryID = json."CountryID",
        SalesTerritory = json."SalesTerritory",
        LatestRecordedPopulation = json."LatestRecordedPopulation",
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_state_province::jsonb) AS json(
        "StateProvinceCode" varchar(5),
        "StateProvinceName" varchar(50),
        "CountryID" integer,
        "SalesTerritory" varchar(50),
        "LatestRecordedPopulation" bigint
    )
    WHERE StateProvinceID = p_state_province_id;
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.update_stock_group_from_json(p_stock_group text, p_stock_group_id integer, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE warehouse.stockgroups SET
        StockGroupName = json."StockGroupName",
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_stock_group::jsonb) AS json("StockGroupName" varchar(50))
    WHERE StockGroupID = p_stock_group_id;
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.update_stock_item_from_json(p_stock_item text, p_stock_item_id integer, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE warehouse.stockitems SET
        StockItemName = COALESCE(json."StockItemName", warehouse.stockitems.StockItemName),
        SupplierID = COALESCE(json."SupplierID", warehouse.stockitems.SupplierID),
        ColorID = json."ColorID",
        UnitPackageID = COALESCE(json."UnitPackageID", warehouse.stockitems.UnitPackageID),
        OuterPackageID = COALESCE(json."OuterPackageID", warehouse.stockitems.OuterPackageID),
        Brand = json."Brand",
        Size = json."Size",
        LeadTimeDays = COALESCE(json."LeadTimeDays", warehouse.stockitems.LeadTimeDays),
        QuantityPerOuter = COALESCE(json."QuantityPerOuter", warehouse.stockitems.QuantityPerOuter),
        IsChillerStock = COALESCE(json."IsChillerStock", warehouse.stockitems.IsChillerStock),
        Barcode = json."Barcode",
        TaxRate = COALESCE(json."TaxRate", warehouse.stockitems.TaxRate),
        UnitPrice = COALESCE(json."UnitPrice", warehouse.stockitems.UnitPrice),
        RecommendedRetailPrice = json."RecommendedRetailPrice",
        TypicalWeightPerUnit = COALESCE(json."TypicalWeightPerUnit", warehouse.stockitems.TypicalWeightPerUnit),
        MarketingComments = json."MarketingComments",
        InternalComments = json."InternalComments",
        Photo = json."Photo",
        CustomFields = json."CustomFields",
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_stock_item::jsonb) AS json(
        "StockItemName" varchar(100),
        "SupplierID" integer,
        "ColorID" integer,
        "UnitPackageID" integer,
        "OuterPackageID" integer,
        "Brand" varchar(50),
        "Size" varchar(20),
        "LeadTimeDays" integer,
        "QuantityPerOuter" integer,
        "IsChillerStock" boolean,
        "Barcode" varchar(50),
        "TaxRate" numeric(18,3),
        "UnitPrice" numeric(18,2),
        "RecommendedRetailPrice" numeric(18,2),
        "TypicalWeightPerUnit" numeric(18,3),
        "MarketingComments" text,
        "InternalComments" text,
        "Photo" bytea,
        "CustomFields" jsonb
    )
    WHERE StockItemID = p_stock_item_id;
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.update_supplier_category_from_json(p_supplier_category text, p_supplier_category_id integer, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE purchasing.suppliercategories SET
        SupplierCategoryName = json."SupplierCategoryName",
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_supplier_category::jsonb) AS json("SupplierCategoryName" varchar(50))
    WHERE SupplierCategoryID = p_supplier_category_id;
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.update_supplier_from_json(p_supplier text, p_supplier_id integer, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE purchasing.suppliers SET
        SupplierName = COALESCE(json."SupplierName", purchasing.suppliers.SupplierName),
        SupplierCategoryID = COALESCE(json."SupplierCategoryID", purchasing.suppliers.SupplierCategoryID),
        PrimaryContactPersonID = COALESCE(json."PrimaryContactPersonID", purchasing.suppliers.PrimaryContactPersonID),
        AlternateContactPersonID = COALESCE(json."AlternateContactPersonID", purchasing.suppliers.AlternateContactPersonID),
        DeliveryMethodID = json."DeliveryMethodID",
        DeliveryCityID = COALESCE(json."DeliveryCityID", purchasing.suppliers.DeliveryCityID),
        PostalCityID = COALESCE(json."PostalCityID", purchasing.suppliers.PostalCityID),
        SupplierReference = json."SupplierReference",
        BankAccountName = COALESCE(json."BankAccountName", purchasing.suppliers.BankAccountName),
        BankAccountBranch = COALESCE(json."BankAccountBranch", purchasing.suppliers.BankAccountBranch),
        BankAccountCode = COALESCE(json."BankAccountCode", purchasing.suppliers.BankAccountCode),
        BankAccountNumber = COALESCE(json."BankAccountNumber", purchasing.suppliers.BankAccountNumber),
        BankInternationalCode = json."BankInternationalCode",
        PaymentDays = COALESCE(json."PaymentDays", purchasing.suppliers.PaymentDays),
        InternalComments = COALESCE(json."InternalComments", purchasing.suppliers.InternalComments),
        PhoneNumber = COALESCE(json."PhoneNumber", purchasing.suppliers.PhoneNumber),
        FaxNumber = COALESCE(json."FaxNumber", purchasing.suppliers.FaxNumber),
        WebsiteURL = COALESCE(json."WebsiteURL", purchasing.suppliers.WebsiteURL),
        DeliveryAddressLine1 = COALESCE(json."DeliveryAddressLine1", purchasing.suppliers.DeliveryAddressLine1),
        DeliveryAddressLine2 = COALESCE(json."DeliveryAddressLine2", purchasing.suppliers.DeliveryAddressLine2),
        DeliveryPostalCode = COALESCE(json."DeliveryPostalCode", purchasing.suppliers.DeliveryPostalCode),
        PostalAddressLine1 = COALESCE(json."PostalAddressLine1", purchasing.suppliers.PostalAddressLine1),
        PostalAddressLine2 = COALESCE(json."PostalAddressLine2", purchasing.suppliers.PostalAddressLine2),
        PostalPostalCode = COALESCE(json."PostalPostalCode", purchasing.suppliers.PostalPostalCode),
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_supplier::jsonb) AS json(
        "SupplierName" varchar(100),
        "SupplierCategoryID" integer,
        "PrimaryContactPersonID" integer,
        "AlternateContactPersonID" integer,
        "DeliveryMethodID" integer,
        "DeliveryCityID" integer,
        "PostalCityID" integer,
        "SupplierReference" varchar(20),
        "BankAccountName" varchar(50),
        "BankAccountBranch" varchar(50),
        "BankAccountCode" varchar(20),
        "BankAccountNumber" varchar(20),
        "BankInternationalCode" varchar(20),
        "PaymentDays" integer,
        "InternalComments" text,
        "PhoneNumber" varchar(20),
        "FaxNumber" varchar(20),
        "WebsiteURL" varchar(256),
        "DeliveryAddressLine1" varchar(60),
        "DeliveryAddressLine2" varchar(60),
        "DeliveryPostalCode" varchar(10),
        "PostalAddressLine1" varchar(60),
        "PostalAddressLine2" varchar(60),
        "PostalPostalCode" varchar(10)
    )
    WHERE SupplierID = p_supplier_id;
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.update_supplier_transaction_from_json(p_supplier_transaction text, p_supplier_transaction_id integer, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE purchasing.suppliertransactions SET
        SupplierID = COALESCE(json."SupplierID", purchasing.suppliertransactions.SupplierID),
        TransactionTypeID = COALESCE(json."TransactionTypeID", purchasing.suppliertransactions.TransactionTypeID),
        PurchaseOrderID = json."PurchaseOrderID",
        PaymentMethodID = json."PaymentMethodID",
        SupplierInvoiceNumber = COALESCE(json."SupplierInvoiceNumber", purchasing.suppliertransactions.SupplierInvoiceNumber),
        TransactionDate = COALESCE(json."TransactionDate", purchasing.suppliertransactions.TransactionDate),
        AmountExcludingTax = COALESCE(json."AmountExcludingTax", purchasing.suppliertransactions.AmountExcludingTax),
        TaxAmount = COALESCE(json."TaxAmount", purchasing.suppliertransactions.TaxAmount),
        TransactionAmount = COALESCE(json."TransactionAmount", purchasing.suppliertransactions.TransactionAmount),
        OutstandingBalance = COALESCE(json."OutstandingBalance", purchasing.suppliertransactions.OutstandingBalance),
        FinalizationDate = COALESCE(json."FinalizationDate", purchasing.suppliertransactions.FinalizationDate),
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_supplier_transaction::jsonb) AS json(
        "SupplierID" integer,
        "TransactionTypeID" integer,
        "PurchaseOrderID" integer,
        "PaymentMethodID" integer,
        "SupplierInvoiceNumber" varchar(20),
        "TransactionDate" date,
        "AmountExcludingTax" numeric(18,2),
        "TaxAmount" numeric(18,2),
        "TransactionAmount" numeric(18,2),
        "OutstandingBalance" numeric(18,2),
        "FinalizationDate" date
    )
    WHERE SupplierTransactionID = p_supplier_transaction_id;
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.update_transaction_type_from_json(p_transaction_type text, p_transaction_type_id integer, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE application.transactiontypes SET
        TransactionTypeName = json."TransactionTypeName",
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_transaction_type::jsonb) AS json("TransactionTypeName" varchar(50))
    WHERE TransactionTypeID = p_transaction_type_id;
END;
$function$;