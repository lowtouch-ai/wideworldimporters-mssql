-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateCustomerFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_customer_from_json(
    p_customer    text,
    p_customer_id integer,
    p_user_id     integer
) RETURNS void AS $$
BEGIN
    -- Fields without ISNULL in source (direct assignment — allows NULL): BuyingGroupID, CreditLimit,
    -- DeliveryRun, RunPosition, DeliveryAddressLine2, PostalAddressLine2
    UPDATE sales.customers
    SET customername               = COALESCE(x."CustomerName",               customers.customername),
        billtocustomerid           = COALESCE(x."BillToCustomerID",           customers.billtocustomerid),
        customercategoryid         = COALESCE(x."CustomerCategoryID",         customers.customercategoryid),
        buyinggroupid              = x."BuyingGroupID",
        primarycontactpersonid     = COALESCE(x."PrimaryContactPersonID",     customers.primarycontactpersonid),
        alternatecontactpersonid   = COALESCE(x."AlternateContactPersonID",   customers.alternatecontactpersonid),
        deliverymethodid           = COALESCE(x."DeliveryMethodID",           customers.deliverymethodid),
        deliverycityid             = COALESCE(x."DeliveryCityID",             customers.deliverycityid),
        postalcityid               = COALESCE(x."PostalCityID",               customers.postalcityid),
        creditlimit                = x."CreditLimit",
        accountopeneddate          = COALESCE(x."AccountOpenedDate",          customers.accountopeneddate),
        standarddiscountpercentage = COALESCE(x."StandardDiscountPercentage", customers.standarddiscountpercentage),
        isstatementsent            = COALESCE(x."IsStatementSent",            customers.isstatementsent),
        isoncredithold             = COALESCE(x."IsOnCreditHold",             customers.isoncredithold),
        paymentdays                = COALESCE(x."PaymentDays",                customers.paymentdays),
        phonenumber                = COALESCE(x."PhoneNumber",                customers.phonenumber),
        faxnumber                  = COALESCE(x."FaxNumber",                  customers.faxnumber),
        deliveryrun                = x."DeliveryRun",
        runposition                = x."RunPosition",
        websiteurl                 = COALESCE(x."WebsiteURL",                 customers.websiteurl),
        deliveryaddressline1       = COALESCE(x."DeliveryAddressLine1",       customers.deliveryaddressline1),
        deliveryaddressline2       = x."DeliveryAddressLine2",
        deliverypostalcode         = COALESCE(x."DeliveryPostalCode",         customers.deliverypostalcode),
        postaladdressline1         = COALESCE(x."PostalAddressLine1",         customers.postaladdressline1),
        postaladdressline2         = x."PostalAddressLine2",
        postalpostalcode           = COALESCE(x."PostalPostalCode",           customers.postalpostalcode),
        lasteditedby               = p_user_id
    FROM jsonb_to_record(p_customer::jsonb) AS x(
        "CustomerName"               varchar(100),
        "BillToCustomerID"           integer,
        "CustomerCategoryID"         integer,
        "BuyingGroupID"              integer,
        "PrimaryContactPersonID"     integer,
        "AlternateContactPersonID"   integer,
        "DeliveryMethodID"           integer,
        "DeliveryCityID"             integer,
        "PostalCityID"               integer,
        "CreditLimit"                numeric(18,2),
        "AccountOpenedDate"          date,
        "StandardDiscountPercentage" numeric(18,3),
        "IsStatementSent"            boolean,
        "IsOnCreditHold"             boolean,
        "PaymentDays"                integer,
        "PhoneNumber"                varchar(20),
        "FaxNumber"                  varchar(20),
        "DeliveryRun"                varchar(5),
        "RunPosition"                varchar(5),
        "WebsiteURL"                 varchar(256),
        "DeliveryAddressLine1"       varchar(60),
        "DeliveryAddressLine2"       varchar(60),
        "DeliveryPostalCode"         varchar(10),
        "PostalAddressLine1"         varchar(60),
        "PostalAddressLine2"         varchar(60),
        "PostalPostalCode"           varchar(10)
    )
    WHERE customers.customerid = p_customer_id;
END;
$$ LANGUAGE plpgsql;
