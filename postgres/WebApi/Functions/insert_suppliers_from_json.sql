-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertSuppliersFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.insert_suppliers_from_json(
    p_suppliers text,
    p_user_id   integer
) RETURNS TABLE(supplierid integer) AS $$
BEGIN
    RETURN QUERY
    INSERT INTO purchasing.suppliers(
        suppliername, suppliercategoryid, primarycontactpersonid, alternatecontactpersonid,
        deliverymethodid, deliverycityid, postalcityid, supplierreference,
        bankaccountname, bankaccountbranch, bankaccountcode, bankaccountnumber,
        bankinternationalcode, paymentdays, internalcomments, phonenumber, faxnumber,
        websiteurl, deliveryaddressline1, deliveryaddressline2, deliverypostalcode,
        postaladdressline1, postaladdressline2, postalpostalcode, lasteditedby
    )
    SELECT
        x."SupplierName", x."SupplierCategoryID", x."PrimaryContactPersonID", x."AlternateContactPersonID",
        x."DeliveryMethodID", x."DeliveryCityID", x."PostalCityID", x."SupplierReference",
        x."BankAccountName", x."BankAccountBranch", x."BankAccountCode", x."BankAccountNumber",
        x."BankInternationalCode", x."PaymentDays", x."InternalComments", x."PhoneNumber", x."FaxNumber",
        x."WebsiteURL", x."DeliveryAddressLine1", x."DeliveryAddressLine2", x."DeliveryPostalCode",
        x."PostalAddressLine1", x."PostalAddressLine2", x."PostalPostalCode", p_user_id
    FROM jsonb_to_recordset(p_suppliers::jsonb) AS x(
        "SupplierName"             varchar(100),
        "SupplierCategoryID"       integer,
        "PrimaryContactPersonID"   integer,
        "AlternateContactPersonID" integer,
        "DeliveryMethodID"         integer,
        "DeliveryCityID"           integer,
        "PostalCityID"             integer,
        "SupplierReference"        varchar(20),
        "BankAccountName"          varchar(50),
        "BankAccountBranch"        varchar(50),
        "BankAccountCode"          varchar(20),
        "BankAccountNumber"        varchar(20),
        "BankInternationalCode"    varchar(20),
        "PaymentDays"              integer,
        "InternalComments"         text,
        "PhoneNumber"              varchar(20),
        "FaxNumber"                varchar(20),
        "WebsiteURL"               varchar(256),
        "DeliveryAddressLine1"     varchar(60),
        "DeliveryAddressLine2"     varchar(60),
        "DeliveryPostalCode"       varchar(10),
        "PostalAddressLine1"       varchar(60),
        "PostalAddressLine2"       varchar(60),
        "PostalPostalCode"         varchar(10)
    )
    RETURNING suppliers.supplierid;
END;
$$ LANGUAGE plpgsql;
