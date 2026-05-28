-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateSupplierFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_supplier_from_json(
    p_supplier text,
    p_supplier_id integer,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    UPDATE purchasing.suppliers SET
        "SupplierName"              = COALESCE(json.supplier_name, purchasing.suppliers."SupplierName"),
        "SupplierCategoryID"        = COALESCE(json.supplier_category_id, purchasing.suppliers."SupplierCategoryID"),
        "PrimaryContactPersonID"    = COALESCE(json.primary_contact_person_id, purchasing.suppliers."PrimaryContactPersonID"),
        "AlternateContactPersonID"  = COALESCE(json.alternate_contact_person_id, purchasing.suppliers."AlternateContactPersonID"),
        "DeliveryMethodID"          = json.delivery_method_id,
        "DeliveryCityID"            = COALESCE(json.delivery_city_id, purchasing.suppliers."DeliveryCityID"),
        "PostalCityID"              = COALESCE(json.postal_city_id, purchasing.suppliers."PostalCityID"),
        "SupplierReference"         = json.supplier_reference,
        "BankAccountName"           = COALESCE(json.bank_account_name, purchasing.suppliers."BankAccountName"),
        "BankAccountBranch"         = COALESCE(json.bank_account_branch, purchasing.suppliers."BankAccountBranch"),
        "BankAccountCode"           = COALESCE(json.bank_account_code, purchasing.suppliers."BankAccountCode"),
        "BankAccountNumber"         = COALESCE(json.bank_account_number, purchasing.suppliers."BankAccountNumber"),
        "BankInternationalCode"     = json.bank_international_code,
        "PaymentDays"               = COALESCE(json.payment_days, purchasing.suppliers."PaymentDays"),
        "InternalComments"          = COALESCE(json.internal_comments, purchasing.suppliers."InternalComments"),
        "PhoneNumber"               = COALESCE(json.phone_number, purchasing.suppliers."PhoneNumber"),
        "FaxNumber"                 = COALESCE(json.fax_number, purchasing.suppliers."FaxNumber"),
        "WebsiteURL"                = COALESCE(json.website_url, purchasing.suppliers."WebsiteURL"),
        "DeliveryAddressLine1"      = COALESCE(json.delivery_address_line1, purchasing.suppliers."DeliveryAddressLine1"),
        "DeliveryAddressLine2"      = COALESCE(json.delivery_address_line2, purchasing.suppliers."DeliveryAddressLine2"),
        "DeliveryPostalCode"        = COALESCE(json.delivery_postal_code, purchasing.suppliers."DeliveryPostalCode"),
        "PostalAddressLine1"        = COALESCE(json.postal_address_line1, purchasing.suppliers."PostalAddressLine1"),
        "PostalAddressLine2"        = COALESCE(json.postal_address_line2, purchasing.suppliers."PostalAddressLine2"),
        "PostalPostalCode"          = COALESCE(json.postal_postal_code, purchasing.suppliers."PostalPostalCode"),
        "LastEditedBy"              = p_user_id
    FROM jsonb_to_recordset(p_supplier::jsonb) AS json(
        supplier_name              varchar(100),
        supplier_category_id       integer,
        primary_contact_person_id  integer,
        alternate_contact_person_id integer,
        delivery_method_id         integer,
        delivery_city_id           integer,
        postal_city_id             integer,
        supplier_reference         varchar(20),
        bank_account_name          varchar(50),
        bank_account_branch        varchar(50),
        bank_account_code          varchar(20),
        bank_account_number        varchar(20),
        bank_international_code    varchar(20),
        payment_days               integer,
        internal_comments          text,
        phone_number               varchar(20),
        fax_number                 varchar(20),
        website_url                varchar(256),
        delivery_address_line1     varchar(60),
        delivery_address_line2     varchar(60),
        delivery_postal_code       varchar(10),
        postal_address_line1       varchar(60),
        postal_address_line2       varchar(60),
        postal_postal_code         varchar(10)
    )
    WHERE purchasing.suppliers."SupplierID" = p_supplier_id;
END;
$$ LANGUAGE plpgsql;
