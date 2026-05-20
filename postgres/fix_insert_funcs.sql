-- Fix: wrap single-object JSON payloads in an array for all 15 webapi insert_* functions,
-- and also applies the PascalCase alias quoting fix (supersedes fix_jsonb_aliases.sql for inserts).
--
-- Root cause 1: The browser app POSTs a single JSON object e.g. {"ColorName":"Red"} but
-- jsonb_to_recordset() requires a JSON array e.g. [{"ColorName":"Red"}].
-- Fix: CASE WHEN jsonb_typeof(...)='array' THEN ... ELSE jsonb_build_array(...) END
--
-- Root cause 2: Unquoted PascalCase aliases in jsonb_to_recordset AS x(...) blocks were
-- lowercased by PostgreSQL, causing NULL extraction from PascalCase JSON keys.
--
-- Applied to: 15 insert_* functions

CREATE OR REPLACE FUNCTION webapi.insert_buying_groups_from_json(p_buying_groups text, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    INSERT INTO sales.buyinggroups (BuyingGroupName, LastEditedBy)
    SELECT x."BuyingGroupName", p_user_id
    FROM jsonb_to_recordset(CASE WHEN jsonb_typeof(p_buying_groups::jsonb)='array' THEN p_buying_groups::jsonb ELSE jsonb_build_array(p_buying_groups::jsonb) END) AS x("BuyingGroupName" varchar(50));
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.insert_cities_from_json(p_cities text, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    INSERT INTO application.cities (CityName, StateProvinceID, LatestRecordedPopulation, LastEditedBy)
    SELECT x."CityName", x."StateProvinceID", x."LatestRecordedPopulation", p_user_id
    FROM jsonb_to_recordset(CASE WHEN jsonb_typeof(p_cities::jsonb)='array' THEN p_cities::jsonb ELSE jsonb_build_array(p_cities::jsonb) END) AS x(
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
    FROM jsonb_to_recordset(CASE WHEN jsonb_typeof(p_colors::jsonb)='array' THEN p_colors::jsonb ELSE jsonb_build_array(p_colors::jsonb) END) AS x("ColorName" varchar(50));
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
    FROM jsonb_to_recordset(CASE WHEN jsonb_typeof(p_countries::jsonb)='array' THEN p_countries::jsonb ELSE jsonb_build_array(p_countries::jsonb) END) AS x(
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
    FROM jsonb_to_recordset(CASE WHEN jsonb_typeof(p_customer_categories::jsonb)='array' THEN p_customer_categories::jsonb ELSE jsonb_build_array(p_customer_categories::jsonb) END) AS x("CustomerCategoryName" varchar(50));
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
    FROM jsonb_to_recordset(CASE WHEN jsonb_typeof(p_customers::jsonb)='array' THEN p_customers::jsonb ELSE jsonb_build_array(p_customers::jsonb) END) AS x(
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
    FROM jsonb_to_recordset(CASE WHEN jsonb_typeof(p_delivery_methods::jsonb)='array' THEN p_delivery_methods::jsonb ELSE jsonb_build_array(p_delivery_methods::jsonb) END) AS x("DeliveryMethodName" varchar(50));
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.insert_package_types_from_json(p_package_types text, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    INSERT INTO warehouse.packagetypes (PackageTypeName, LastEditedBy)
    SELECT x."PackageTypeName", p_user_id
    FROM jsonb_to_recordset(CASE WHEN jsonb_typeof(p_package_types::jsonb)='array' THEN p_package_types::jsonb ELSE jsonb_build_array(p_package_types::jsonb) END) AS x("PackageTypeName" varchar(50));
END;
$function$;

CREATE OR REPLACE FUNCTION webapi.insert_payment_methods_from_json(p_payment_methods text, p_user_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    INSERT INTO application.paymentmethods (PaymentMethodName, LastEditedBy)
    SELECT x."PaymentMethodName", p_user_id
    FROM jsonb_to_recordset(CASE WHEN jsonb_typeof(p_payment_methods::jsonb)='array' THEN p_payment_methods::jsonb ELSE jsonb_build_array(p_payment_methods::jsonb) END) AS x("PaymentMethodName" varchar(50));
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
    FROM jsonb_to_recordset(CASE WHEN jsonb_typeof(p_state_provinces::jsonb)='array' THEN p_state_provinces::jsonb ELSE jsonb_build_array(p_state_provinces::jsonb) END) AS x(
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
    FROM jsonb_to_recordset(CASE WHEN jsonb_typeof(p_stock_groups::jsonb)='array' THEN p_stock_groups::jsonb ELSE jsonb_build_array(p_stock_groups::jsonb) END) AS x("StockGroupName" varchar(50));
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
    FROM jsonb_to_recordset(CASE WHEN jsonb_typeof(p_stock_items::jsonb)='array' THEN p_stock_items::jsonb ELSE jsonb_build_array(p_stock_items::jsonb) END) AS x(
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
    FROM jsonb_to_recordset(CASE WHEN jsonb_typeof(p_supplier_categories::jsonb)='array' THEN p_supplier_categories::jsonb ELSE jsonb_build_array(p_supplier_categories::jsonb) END) AS x("SupplierCategoryName" varchar(50));
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
    FROM jsonb_to_recordset(CASE WHEN jsonb_typeof(p_suppliers::jsonb)='array' THEN p_suppliers::jsonb ELSE jsonb_build_array(p_suppliers::jsonb) END) AS x(
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
    FROM jsonb_to_recordset(CASE WHEN jsonb_typeof(p_transaction_types::jsonb)='array' THEN p_transaction_types::jsonb ELSE jsonb_build_array(p_transaction_types::jsonb) END) AS x("TransactionTypeName" varchar(50));
END;
$function$;