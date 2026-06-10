DO $body$
DECLARE
    v_currentdatetime timestamp := '2020-01-01';
    v_endoftime timestamp := '99991231 23:59:59.9999999';
    v_bank varchar(50) := NULL;
    v_mycityid integer := NULL;
    v_mycityname varchar(50) := NULL;
    v_mystateprovincecode varchar(5) := NULL;
    v_mystateprovincename varchar(50) := NULL;
    v_myareacode varchar(3) := NULL;
BEGIN
-- City Variables
SELECT CityID INTO v_mycityid FROM application.cities WHERE CityName = 'San Francisco' AND StateProvinceID IS NOT NULL LIMIT 1;
SELECT '415' INTO v_myareacode;

/* A Datum Corporation ----------------------------------------------------------------*/

v_bank := 'Woodgrove Bank ' || v_mycityname;

INSERT INTO purchasing.suppliers
  ( SupplierID, SupplierName
  , SupplierCategoryID
  , PrimaryContactPersonID
  , AlternateContactPersonID
  , DeliveryMethodID
  , DeliveryCityID, PostalCityID
  , SupplierReference
  , BankAccountName, BankAccountBranch, BankAccountCode, BankAccountNumber, BankInternationalCode
  , PaymentDays, InternalComments
  , PhoneNumber, FaxNumber
  , WebsiteURL
  , DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation
  , PostalAddressLine1, PostalAddressLine2, PostalPostalCode
  , LastEditedBy, ValidFrom, ValidTo)
VALUES
  ( 1, 'A Datum Corporation'
  , (SELECT SupplierCategoryID FROM purchasing.suppliercategories WHERE SupplierCategoryName = 'Novelty Goods Supplier' LIMIT 1)
  , (SELECT PersonID FROM application.people WHERE FullName = 'Reio Kabin' LIMIT 1)
  , (SELECT PersonID FROM application.people WHERE FullName = 'Oliver Kivi' LIMIT 1)
  , (SELECT DeliveryMethodID FROM application.deliverymethods WHERE DeliveryMethodName = 'Road Freight' LIMIT 1)
  , v_mycityid, v_mycityid
  , 'AA20384'
  , 'A Datum Corporation', v_bank, '356981', '8575824136', '25986'
  , 14, NULL
  , '(' || v_myareacode || ') 555-0100', '(' || v_myareacode || ') 555-0101'
  , 'http://www.adatum.com'
  , 'Suite 10','183838 Southwest Boulevard','46077',NULL
  , 'PO Box 1039', 'Surrey', '46077'
  , 1, v_currentdatetime, v_endoftime);

/* Contoso, Ltd. ----------------------------------------------------------------------*/

v_bank := 'Woodgrove Bank ' || v_mycityname;

INSERT INTO purchasing.suppliers
  ( SupplierID, SupplierName
  , SupplierCategoryID
  , PrimaryContactPersonID
  , AlternateContactPersonID
  , DeliveryMethodID
  , DeliveryCityID, PostalCityID
  , SupplierReference
  , BankAccountName, BankAccountBranch, BankAccountCode, BankAccountNumber, BankInternationalCode
  , PaymentDays, InternalComments
  , PhoneNumber, FaxNumber
  , WebsiteURL
  , DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation
  , PostalAddressLine1, PostalAddressLine2, PostalPostalCode
  , LastEditedBy, ValidFrom, ValidTo)
VALUES
  ( 2, 'Contoso, Ltd.'
  , (SELECT SupplierCategoryID FROM purchasing.suppliercategories WHERE SupplierCategoryName = 'Novelty Goods Supplier' LIMIT 1)
  , (SELECT PersonID FROM application.people WHERE FullName = 'Hanna Mihhailov' LIMIT 1)
  , (SELECT PersonID FROM application.people WHERE FullName = 'Paulus Lippmaa' LIMIT 1)
  , (SELECT DeliveryMethodID FROM application.deliverymethods WHERE DeliveryMethodName = 'Refrigerated Road Freight' LIMIT 1)
  , v_mycityid, v_mycityid
  , 'B2084020'
  , 'Contoso Ltd', v_bank, '358698', '4587965215', '25868'
  , 7, NULL
  , '(' || v_myareacode || ') 555-0100', '(' || v_myareacode || ') 555-0101'
  , 'http://www.contoso.com'
  , 'Unit 2', '2934 Night Road','98253',NULL
  , 'PO Box 1012', 'Jolimont', '98253'
  , 1, v_currentdatetime, v_endoftime
  );

/* Consolidated Messenger -------------------------------------------------------------*/

v_bank := 'Woodgrove Bank ' || v_mycityname;

INSERT INTO purchasing.suppliers
  ( SupplierID, SupplierName
  , SupplierCategoryID
  , PrimaryContactPersonID
  , AlternateContactPersonID
  , DeliveryMethodID
  , DeliveryCityID, PostalCityID
  , SupplierReference
  , BankAccountName, BankAccountBranch, BankAccountCode, BankAccountNumber, BankInternationalCode
  , PaymentDays, InternalComments
  , PhoneNumber, FaxNumber
  , WebsiteURL
  , DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation
  , PostalAddressLine1, PostalAddressLine2, PostalPostalCode
  , LastEditedBy, ValidFrom, ValidTo)
VALUES
 ( 3, 'Consolidated Messenger'
 , (SELECT SupplierCategoryID FROM purchasing.suppliercategories WHERE SupplierCategoryName = 'Courier' LIMIT 1)
 , (SELECT PersonID FROM application.people WHERE FullName = 'Kerstin Parn' LIMIT 1)
 , (SELECT PersonID FROM application.people WHERE FullName = 'Helen Ahven' LIMIT 1)
 , (SELECT DeliveryMethodID FROM application.deliverymethods WHERE DeliveryMethodName = 'NULL' LIMIT 1)
 , v_mycityid, v_mycityid
 , '209340283'
 , 'Consolidated Messenger', v_bank, '354269','3254872158','45698'
 , 30, NULL
 , '(' || v_myareacode || ') 555-0100','(' || v_myareacode || ') 555-0101'
 ,'http://www.consolidatedmessenger.com'
 , '','894 Market Day Street','94101',NULL
 , 'PO Box 1014','West Mont','94101'
 , 1, v_currentdatetime, v_endoftime
 );

/* Fabrikam, Inc. ---------------------------------------------------------------------*/

v_bank := 'Woodgrove Bank ' || v_mycityname;

INSERT INTO purchasing.suppliers
  ( SupplierID, SupplierName
  , SupplierCategoryID
  , PrimaryContactPersonID
  , AlternateContactPersonID
  , DeliveryMethodID
  , DeliveryCityID, PostalCityID
  , SupplierReference
  , BankAccountName, BankAccountBranch, BankAccountCode, BankAccountNumber, BankInternationalCode
  , PaymentDays, InternalComments
  , PhoneNumber, FaxNumber
  , WebsiteURL
  , DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation
  , PostalAddressLine1, PostalAddressLine2, PostalPostalCode
  , LastEditedBy, ValidFrom, ValidTo)
VALUES
  ( 4, 'Fabrikam, Inc.'
  , (SELECT SupplierCategoryID FROM purchasing.suppliercategories WHERE SupplierCategoryName = 'Clothing Supplier' LIMIT 1)
  , (SELECT PersonID FROM application.people WHERE FullName = 'Bill Lawson' LIMIT 1)
  , (SELECT PersonID FROM application.people WHERE FullName = 'Helen Moore' LIMIT 1)
  , (SELECT DeliveryMethodID FROM application.deliverymethods WHERE DeliveryMethodName = 'Road Freight' LIMIT 1)
  , v_mycityid, v_mycityid
  , '293092'
  , 'Fabrikam Inc', v_bank, '789568', '4125863879', '12546'
  , 30, NULL
  , '(' || v_myareacode || ') 555-0104', '(' || v_myareacode || ') 555-0108'
  , 'http://www.fabrikam.com'
  , 'Level 2', '393999 Woodberg Road', '40351', NULL
  , 'PO Box 301', 'Eaglemont', '40351'
  , 1, v_currentdatetime, v_endoftime
  );

/* Graphic Design Institute -----------------------------------------------------------*/

v_bank := 'Woodgrove Bank ' || v_mycityname;

INSERT INTO purchasing.suppliers
  ( SupplierID, SupplierName
  , SupplierCategoryID
  , PrimaryContactPersonID
  , AlternateContactPersonID
  , DeliveryMethodID
  , DeliveryCityID, PostalCityID
  , SupplierReference
  , BankAccountName, BankAccountBranch, BankAccountCode, BankAccountNumber, BankInternationalCode
  , PaymentDays, InternalComments
  , PhoneNumber, FaxNumber
  , WebsiteURL
  , DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation
  , PostalAddressLine1, PostalAddressLine2, PostalPostalCode
  , LastEditedBy, ValidFrom, ValidTo)
VALUES
  ( 5, 'Graphic Design Institute'
  , (SELECT SupplierCategoryID FROM purchasing.suppliercategories WHERE SupplierCategoryName = 'Novelty Goods Supplier' LIMIT 1)
  , (SELECT PersonID FROM application.people WHERE FullName = 'Penny Buck' LIMIT 1)
  , (SELECT PersonID FROM application.people WHERE FullName = 'Donna Smith' LIMIT 1)
  , (SELECT DeliveryMethodID FROM application.deliverymethods WHERE DeliveryMethodName = 'Refrigerated Air Freight' LIMIT 1)
  , v_mycityid, v_mycityid
  , '0880-39-22'
  , 'Graphic Design Institute', v_bank, '563215', '1025869354', '32587'
  , 14, NULL
  , '(' || v_myareacode || ') 555-0105', '(' || v_myareacode || ') 555-0106'
  , 'http://www.graphicdesigninstitute.com'
  , '', '45th Street', '64847', NULL
  , 'PO Box 393', 'Willow', '64847'
  , 1, v_currentdatetime, v_endoftime
  );

/* Humongous Insurance ----------------------------------------------------------------*/

v_bank := 'Woodgrove Bank ' || v_mycityname;

INSERT INTO purchasing.suppliers
  ( SupplierID, SupplierName
  , SupplierCategoryID
  , PrimaryContactPersonID
  , AlternateContactPersonID
  , DeliveryMethodID
  , DeliveryCityID, PostalCityID
  , SupplierReference
  , BankAccountName, BankAccountBranch, BankAccountCode, BankAccountNumber, BankInternationalCode
  , PaymentDays, InternalComments
  , PhoneNumber, FaxNumber
  , WebsiteURL
  , DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation
  , PostalAddressLine1, PostalAddressLine2, PostalPostalCode
  , LastEditedBy, ValidFrom, ValidTo)
VALUES
  ( 6, 'Humongous Insurance'
  , (SELECT SupplierCategoryID FROM purchasing.suppliercategories WHERE SupplierCategoryName = 'Insurance Services Supplier' LIMIT 1)
  , (SELECT PersonID FROM application.people WHERE FullName = 'Madelaine  Cartier' LIMIT 1)
  , (SELECT PersonID FROM application.people WHERE FullName = 'Annette Talon' LIMIT 1)
  , (SELECT DeliveryMethodID FROM application.deliverymethods WHERE DeliveryMethodName = 'NULL' LIMIT 1)
  , v_mycityid, v_mycityid
  , '082420938'
  , 'Humongous Insurance', v_bank, '325001', '2569874521', '32569'
  , 14, NULL
  , '(' || v_myareacode || ') 555-0105', '(' || v_myareacode || ') 555-0100'
  , 'http://www.humongousinsurance.com'
  , '', '9893 Mount Norris Road', '37770', NULL
  , 'PO Box 94829', 'Boxville', '37770'
  , 1, v_currentdatetime, v_endoftime
  );

/* Litware, Inc. ----------------------------------------------------------------------*/

v_bank := 'Woodgrove Bank ' || v_mycityname;

INSERT INTO purchasing.suppliers
  ( SupplierID, SupplierName
  , SupplierCategoryID
  , PrimaryContactPersonID
  , AlternateContactPersonID
  , DeliveryMethodID
  , DeliveryCityID, PostalCityID
  , SupplierReference
  , BankAccountName, BankAccountBranch, BankAccountCode, BankAccountNumber, BankInternationalCode
  , PaymentDays, InternalComments
  , PhoneNumber, FaxNumber
  , WebsiteURL
  , DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation
  , PostalAddressLine1, PostalAddressLine2, PostalPostalCode
  , LastEditedBy, ValidFrom, ValidTo)
VALUES
  ( 7, 'Litware, Inc.'
  , (SELECT SupplierCategoryID FROM purchasing.suppliercategories WHERE SupplierCategoryName = 'Packaging Supplier' LIMIT 1)
  , (SELECT PersonID FROM application.people WHERE FullName = 'Elias Myllari' LIMIT 1)
  , (SELECT PersonID FROM application.people WHERE FullName = 'Vilma Niva' LIMIT 1)
  , (SELECT DeliveryMethodID FROM application.deliverymethods WHERE DeliveryMethodName = 'Courier' LIMIT 1)
  , v_mycityid, v_mycityid
  , 'BC0280982'
  , 'Litware Inc', v_bank, '358769', '3256896325', '21445'
  , 30, NULL
  , '(' || v_myareacode || ') 555-0108', '(' || v_myareacode || ') 555-0104'
  , 'http://www.litwareinc.com'
  , 'Level 3', '19 Le Church Street', '95245', NULL
  , 'PO Box 20290', 'Jackson', '95245'
  , 1, v_currentdatetime, v_endoftime
  );

/* Lucerne Publishing -----------------------------------------------------------------*/

v_bank := 'Woodgrove Bank ' || v_mycityname;

INSERT INTO purchasing.suppliers
  ( SupplierID, SupplierName
  , SupplierCategoryID
  , PrimaryContactPersonID
  , AlternateContactPersonID
  , DeliveryMethodID
  , DeliveryCityID, PostalCityID
  , SupplierReference
  , BankAccountName, BankAccountBranch, BankAccountCode, BankAccountNumber, BankInternationalCode
  , PaymentDays, InternalComments
  , PhoneNumber, FaxNumber
  , WebsiteURL
  , DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation
  , PostalAddressLine1, PostalAddressLine2, PostalPostalCode
  , LastEditedBy, ValidFrom, ValidTo)
VALUES
  ( 8, 'Lucerne Publishing'
  , (SELECT SupplierCategoryID FROM purchasing.suppliercategories WHERE SupplierCategoryName = 'Novelty Goods Supplier' LIMIT 1)
  , (SELECT PersonID FROM application.people WHERE FullName = 'Prem Prabhu' LIMIT 1)
  , (SELECT PersonID FROM application.people WHERE FullName = 'Sunita Jadhav' LIMIT 1)
  , (SELECT DeliveryMethodID FROM application.deliverymethods WHERE DeliveryMethodName = 'Refrigerated Air Freight' LIMIT 1)
  , v_mycityid, v_mycityid
  , 'JQ082304802'
  , 'Lucerne Publishing', v_bank, '654789', '3254123658', '21569'
  , 30, NULL
  , '(' || v_myareacode || ') 555-0103', '(' || v_myareacode || ') 555-0105'
  , 'http://www.lucernepublishing.com'
  , 'Suite 34', '949482 Miller Boulevard', '37659', NULL
  , 'PO Box 8747', 'Westerfold', '37659'
  , 1, v_currentdatetime, v_endoftime
  );

/* Lucerne Publishing -----------------------------------------------------------------*/

v_bank := 'Woodgrove Bank ' || v_mycityname;

INSERT INTO purchasing.suppliers
  ( SupplierID, SupplierName
  , SupplierCategoryID
  , PrimaryContactPersonID
  , AlternateContactPersonID
  , DeliveryMethodID
  , DeliveryCityID, PostalCityID
  , SupplierReference
  , BankAccountName, BankAccountBranch, BankAccountCode, BankAccountNumber, BankInternationalCode
  , PaymentDays, InternalComments
  , PhoneNumber, FaxNumber
  , WebsiteURL
  , DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation
  , PostalAddressLine1, PostalAddressLine2, PostalPostalCode
  , LastEditedBy, ValidFrom, ValidTo)
VALUES
  ( 9, 'Nod Publishers'
  , (SELECT SupplierCategoryID FROM purchasing.suppliercategories WHERE SupplierCategoryName = 'Novelty Goods Supplier' LIMIT 1)
  , (SELECT PersonID FROM application.people WHERE FullName = 'Marcos Costa' LIMIT 1)
  , (SELECT PersonID FROM application.people WHERE FullName = 'Matheus Oliveira' LIMIT 1)
  , (SELECT DeliveryMethodID FROM application.deliverymethods WHERE DeliveryMethodName = 'Refrigerated Air Freight' LIMIT 1)
  , v_mycityid, v_mycityid
  , 'GL08029802'
  , 'Nod Publishers', v_bank, '365985', '2021545878', '48758'
  , 7, 'Marcos is not in on Mondays'
  , '(' || v_myareacode || ') 555-0100', '(' || v_myareacode || ') 555-0101'
  , 'http://www.nodpublishers.com'
  , 'Level 1', '389 King Street', '27906', NULL
  , 'PO Box 3390', 'Anderson', '27906'
  , 1, v_currentdatetime, v_endoftime
  );

/* Northwind Electric Cars ------------------------------------------------------------*/

v_bank := 'Woodgrove Bank ' || v_mycityname;

INSERT INTO purchasing.suppliers
  ( SupplierID, SupplierName
  , SupplierCategoryID
  , PrimaryContactPersonID
  , AlternateContactPersonID
  , DeliveryMethodID
  , DeliveryCityID, PostalCityID
  , SupplierReference
  , BankAccountName, BankAccountBranch, BankAccountCode, BankAccountNumber, BankInternationalCode
  , PaymentDays, InternalComments
  , PhoneNumber, FaxNumber
  , WebsiteURL
  , DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation
  , PostalAddressLine1, PostalAddressLine2, PostalPostalCode
  , LastEditedBy, ValidFrom, ValidTo)
VALUES
  (10, 'Northwind Electric Cars'
  , (SELECT SupplierCategoryID FROM purchasing.suppliercategories WHERE SupplierCategoryName = 'Toy Supplier' LIMIT 1)
  , (SELECT PersonID FROM application.people WHERE FullName = 'Eliza Soderberg' LIMIT 1)
  , (SELECT PersonID FROM application.people WHERE FullName = 'Sara Karlsson' LIMIT 1)
  , (SELECT DeliveryMethodID FROM application.deliverymethods WHERE DeliveryMethodName = 'Air Freight' LIMIT 1)
  , v_mycityid, v_mycityid
  , 'ML0300202'
  , 'Northwind Electric Cars', v_bank, '325447', '3258786987', '36214'
  , 30, NULL
  , '(' || v_myareacode || ') 555-0105', '(' || v_myareacode || ') 555-0104'
  , 'http://www.northwindelectriccars.com'
  , '', '440 New Road', '07860', NULL
  , 'PO Box 30920', 'Arlington', '07860'
  , 1, v_currentdatetime, v_endoftime
  );

/* Trey Research ----------------------------------------------------------------------*/

v_bank := 'Woodgrove Bank ' || v_mycityname;

INSERT INTO purchasing.suppliers
  ( SupplierID, SupplierName
  , SupplierCategoryID
  , PrimaryContactPersonID
  , AlternateContactPersonID
  , DeliveryMethodID
  , DeliveryCityID, PostalCityID
  , SupplierReference
  , BankAccountName, BankAccountBranch, BankAccountCode, BankAccountNumber, BankInternationalCode
  , PaymentDays, InternalComments
  , PhoneNumber, FaxNumber
  , WebsiteURL
  , DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation
  , PostalAddressLine1, PostalAddressLine2, PostalPostalCode
  , LastEditedBy, ValidFrom, ValidTo)
VALUES
  (11, 'Trey Research'
  , (SELECT SupplierCategoryID FROM purchasing.suppliercategories WHERE SupplierCategoryName = 'Marketing Services Supplier' LIMIT 1)
  , (SELECT PersonID FROM application.people WHERE FullName = 'Donald Jones' LIMIT 1)
  , (SELECT PersonID FROM application.people WHERE FullName = 'Sharon Graham' LIMIT 1)
  , (SELECT DeliveryMethodID FROM application.deliverymethods WHERE DeliveryMethodName = 'NULL' LIMIT 1)
  , v_mycityid, v_mycityid
  , '082304822'
  , 'Trey Research', v_bank, '658968', '1254785321', '56958'
  , 7, NULL
  , '(' || v_myareacode || ') 555-0103', '(' || v_myareacode || ') 555-0101'
  , 'http://www.treyresearch.net'
  , 'Level 43', '9401 Polar Avenue', '57543', NULL
  , 'PO  Box 595', 'Port Fairy', '57543'
  , 1, v_currentdatetime, v_endoftime
  );

/* The Phone Company ------------------------------------------------------------------*/

v_bank := 'Woodgrove Bank ' || v_mycityname;

INSERT INTO purchasing.suppliers
  ( SupplierID, SupplierName
  , SupplierCategoryID
  , PrimaryContactPersonID
  , AlternateContactPersonID
  , DeliveryMethodID
  , DeliveryCityID, PostalCityID
  , SupplierReference
  , BankAccountName, BankAccountBranch, BankAccountCode, BankAccountNumber, BankInternationalCode
  , PaymentDays, InternalComments
  , PhoneNumber, FaxNumber
  , WebsiteURL
  , DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation
  , PostalAddressLine1, PostalAddressLine2, PostalPostalCode
  , LastEditedBy, ValidFrom, ValidTo)
VALUES
  (12, 'The Phone Company'
  , (SELECT SupplierCategoryID FROM purchasing.suppliercategories WHERE SupplierCategoryName = 'Novelty Goods Supplier' LIMIT 1)
  , (SELECT PersonID FROM application.people WHERE FullName = 'Hai Dam' LIMIT 1)
  , (SELECT PersonID FROM application.people WHERE FullName = 'Thanh Dinh' LIMIT 1)
  , (SELECT DeliveryMethodID FROM application.deliverymethods WHERE DeliveryMethodName = 'Road Freight' LIMIT 1)
  , v_mycityid, v_mycityid
  , '237408032'
  , 'The Phone Company', v_bank, '214568', '7896236589', '25478'
  , 30, NULL
  , '(' || v_myareacode || ') 555-0105', '(' || v_myareacode || ') 555-0105'
  , 'http://www.thephone-company.com'
  , 'Level 83', '339 Toorak Road', '56732', NULL
  , 'PO Box 3837', 'Ferny Wood', '56732'
  , 1, v_currentdatetime, v_endoftime
  );

/* Woodgrove Bank ---------------------------------------------------------------------*/

v_bank := 'Woodgrove Bank ' || v_mycityname;

INSERT INTO purchasing.suppliers
  ( SupplierID, SupplierName
  , SupplierCategoryID
  , PrimaryContactPersonID
  , AlternateContactPersonID
  , DeliveryMethodID
  , DeliveryCityID, PostalCityID
  , SupplierReference
  , BankAccountName, BankAccountBranch, BankAccountCode, BankAccountNumber, BankInternationalCode
  , PaymentDays, InternalComments
  , PhoneNumber, FaxNumber
  , WebsiteURL
  , DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation
  , PostalAddressLine1, PostalAddressLine2, PostalPostalCode
  , LastEditedBy, ValidFrom, ValidTo)
VALUES
  (13, 'Woodgrove Bank'
  , (SELECT SupplierCategoryID FROM purchasing.suppliercategories WHERE SupplierCategoryName = 'Financial Services Supplier' LIMIT 1)
  , (SELECT PersonID FROM application.people WHERE FullName = 'Hubert Helms' LIMIT 1)
  , (SELECT PersonID FROM application.people WHERE FullName = 'Donald Small' LIMIT 1)
  , (SELECT DeliveryMethodID FROM application.deliverymethods WHERE DeliveryMethodName = 'NULL' LIMIT 1)
  , v_mycityid, v_mycityid
  , '028034202'
  , 'Woodgrove Bank', v_bank, '325698', '2147825698', '65893'
  , 7, 'Only speak to Donald if Hubert really is not available'
  , '(' || v_myareacode || ') 555-0103', '(' || v_myareacode || ') 555-0107'
  , 'http://www.woodgrovebank.com'
  , 'Level 3', '8488 Vienna Boulevard', '94101', NULL
  , 'PO Box 2390', 'Canterbury', '94101'
  , 1, v_currentdatetime, v_endoftime
  );

UPDATE purchasing.suppliers AS s
   SET DeliveryLocation = c.Location,
       ValidFrom = (v_currentdatetime + (CEILING(RANDOM() * 5)) * INTERVAL '1 minute')
  FROM application.cities AS c
 WHERE s.DeliveryCityID = c.CityID;
END;
$body$;
