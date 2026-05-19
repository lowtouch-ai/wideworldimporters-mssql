-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertCustomersFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.insert_customers_from_json(
    p_customers text,
    p_user_id integer
) RETURNS void AS $$
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
        x.CustomerName, x.BillToCustomerID, x.CustomerCategoryID, x.BuyingGroupID,
        x.PrimaryContactPersonID, x.AlternateContactPersonID, x.DeliveryMethodID,
        x.DeliveryCityID, x.PostalCityID, x.CreditLimit, x.AccountOpenedDate,
        x.StandardDiscountPercentage, x.IsStatementSent, x.IsOnCreditHold,
        x.PaymentDays, x.PhoneNumber, x.FaxNumber, x.DeliveryRun, x.RunPosition,
        x.WebsiteURL, x.DeliveryAddressLine1, x.DeliveryAddressLine2, x.DeliveryPostalCode,
        x.PostalAddressLine1, x.PostalAddressLine2, x.PostalPostalCode, p_user_id
    FROM jsonb_to_recordset(p_customers::jsonb) AS x(
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
    );
END;
$$ LANGUAGE plpgsql;
