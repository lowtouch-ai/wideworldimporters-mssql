-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateCustomerFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_customer_from_json(
    p_customer text,
    p_customer_id integer,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    UPDATE sales.customers SET
        CustomerName = COALESCE(json.CustomerName, sales.customers.CustomerName),
        BillToCustomerID = COALESCE(json.BillToCustomerID, sales.customers.BillToCustomerID),
        CustomerCategoryID = COALESCE(json.CustomerCategoryID, sales.customers.CustomerCategoryID),
        BuyingGroupID = json.BuyingGroupID,
        PrimaryContactPersonID = COALESCE(json.PrimaryContactPersonID, sales.customers.PrimaryContactPersonID),
        AlternateContactPersonID = COALESCE(json.AlternateContactPersonID, sales.customers.AlternateContactPersonID),
        DeliveryMethodID = COALESCE(json.DeliveryMethodID, sales.customers.DeliveryMethodID),
        DeliveryCityID = COALESCE(json.DeliveryCityID, sales.customers.DeliveryCityID),
        PostalCityID = COALESCE(json.PostalCityID, sales.customers.PostalCityID),
        CreditLimit = json.CreditLimit,
        AccountOpenedDate = COALESCE(json.AccountOpenedDate, sales.customers.AccountOpenedDate),
        StandardDiscountPercentage = COALESCE(json.StandardDiscountPercentage, sales.customers.StandardDiscountPercentage),
        IsStatementSent = COALESCE(json.IsStatementSent, sales.customers.IsStatementSent),
        IsOnCreditHold = COALESCE(json.IsOnCreditHold, sales.customers.IsOnCreditHold),
        PaymentDays = COALESCE(json.PaymentDays, sales.customers.PaymentDays),
        PhoneNumber = COALESCE(json.PhoneNumber, sales.customers.PhoneNumber),
        FaxNumber = COALESCE(json.FaxNumber, sales.customers.FaxNumber),
        DeliveryRun = json.DeliveryRun,
        RunPosition = json.RunPosition,
        WebsiteURL = COALESCE(json.WebsiteURL, sales.customers.WebsiteURL),
        DeliveryAddressLine1 = COALESCE(json.DeliveryAddressLine1, sales.customers.DeliveryAddressLine1),
        DeliveryAddressLine2 = json.DeliveryAddressLine2,
        DeliveryPostalCode = COALESCE(json.DeliveryPostalCode, sales.customers.DeliveryPostalCode),
        PostalAddressLine1 = COALESCE(json.PostalAddressLine1, sales.customers.PostalAddressLine1),
        PostalAddressLine2 = json.PostalAddressLine2,
        PostalPostalCode = COALESCE(json.PostalPostalCode, sales.customers.PostalPostalCode),
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_customer::jsonb) AS json(
        CustomerName varchar(100),
        BillToCustomerID integer,
        CustomerCategoryID integer,
        BuyingGroupID integer,
        PrimaryContactPersonID integer,
        AlternateContactPersonID integer,
        DeliveryMethodID integer,
        DeliveryCityID integer,
        PostalCityID integer,
        CreditLimit numeric(18,2),
        AccountOpenedDate date,
        StandardDiscountPercentage numeric(18,3),
        IsStatementSent boolean,
        IsOnCreditHold boolean,
        PaymentDays integer,
        PhoneNumber varchar(20),
        FaxNumber varchar(20),
        DeliveryRun varchar(5),
        RunPosition varchar(5),
        WebsiteURL varchar(256),
        DeliveryAddressLine1 varchar(60),
        DeliveryAddressLine2 varchar(60),
        DeliveryPostalCode varchar(10),
        PostalAddressLine1 varchar(60),
        PostalAddressLine2 varchar(60),
        PostalPostalCode varchar(10)
    )
    WHERE CustomerID = p_customer_id;
END;
$$ LANGUAGE plpgsql;
