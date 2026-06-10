-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateSupplierFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_supplier_from_json(
    p_supplier text,
    p_supplier_id integer,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    UPDATE purchasing.suppliers SET
        SupplierName = COALESCE(json.SupplierName, purchasing.suppliers.SupplierName),
        SupplierCategoryID = COALESCE(json.SupplierCategoryID, purchasing.suppliers.SupplierCategoryID),
        PrimaryContactPersonID = COALESCE(json.PrimaryContactPersonID, purchasing.suppliers.PrimaryContactPersonID),
        AlternateContactPersonID = COALESCE(json.AlternateContactPersonID, purchasing.suppliers.AlternateContactPersonID),
        DeliveryMethodID = json.DeliveryMethodID,
        DeliveryCityID = COALESCE(json.DeliveryCityID, purchasing.suppliers.DeliveryCityID),
        PostalCityID = COALESCE(json.PostalCityID, purchasing.suppliers.PostalCityID),
        SupplierReference = json.SupplierReference,
        BankAccountName = COALESCE(json.BankAccountName, purchasing.suppliers.BankAccountName),
        BankAccountBranch = COALESCE(json.BankAccountBranch, purchasing.suppliers.BankAccountBranch),
        BankAccountCode = COALESCE(json.BankAccountCode, purchasing.suppliers.BankAccountCode),
        BankAccountNumber = COALESCE(json.BankAccountNumber, purchasing.suppliers.BankAccountNumber),
        BankInternationalCode = json.BankInternationalCode,
        PaymentDays = COALESCE(json.PaymentDays, purchasing.suppliers.PaymentDays),
        InternalComments = COALESCE(json.InternalComments, purchasing.suppliers.InternalComments),
        PhoneNumber = COALESCE(json.PhoneNumber, purchasing.suppliers.PhoneNumber),
        FaxNumber = COALESCE(json.FaxNumber, purchasing.suppliers.FaxNumber),
        WebsiteURL = COALESCE(json.WebsiteURL, purchasing.suppliers.WebsiteURL),
        DeliveryAddressLine1 = COALESCE(json.DeliveryAddressLine1, purchasing.suppliers.DeliveryAddressLine1),
        DeliveryAddressLine2 = COALESCE(json.DeliveryAddressLine2, purchasing.suppliers.DeliveryAddressLine2),
        DeliveryPostalCode = COALESCE(json.DeliveryPostalCode, purchasing.suppliers.DeliveryPostalCode),
        PostalAddressLine1 = COALESCE(json.PostalAddressLine1, purchasing.suppliers.PostalAddressLine1),
        PostalAddressLine2 = COALESCE(json.PostalAddressLine2, purchasing.suppliers.PostalAddressLine2),
        PostalPostalCode = COALESCE(json.PostalPostalCode, purchasing.suppliers.PostalPostalCode),
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_supplier::jsonb) AS json(
        SupplierName varchar(100),
        SupplierCategoryID integer,
        PrimaryContactPersonID integer,
        AlternateContactPersonID integer,
        DeliveryMethodID integer,
        DeliveryCityID integer,
        PostalCityID integer,
        SupplierReference varchar(20),
        BankAccountName varchar(50),
        BankAccountBranch varchar(50),
        BankAccountCode varchar(20),
        BankAccountNumber varchar(20),
        BankInternationalCode varchar(20),
        PaymentDays integer,
        InternalComments text,
        PhoneNumber varchar(20),
        FaxNumber varchar(20),
        WebsiteURL varchar(256),
        DeliveryAddressLine1 varchar(60),
        DeliveryAddressLine2 varchar(60),
        DeliveryPostalCode varchar(10),
        PostalAddressLine1 varchar(60),
        PostalAddressLine2 varchar(60),
        PostalPostalCode varchar(10)
    )
    WHERE SupplierID = p_supplier_id;
END;
$$ LANGUAGE plpgsql;
