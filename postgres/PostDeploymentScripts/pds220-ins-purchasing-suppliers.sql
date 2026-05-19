-- Inserting purchasing.suppliers
DO $$
DECLARE
  v_bank                  VARCHAR(50);
  v_my_city_id            INTEGER;
  v_my_city_name          VARCHAR(50);
  v_my_state_province_code VARCHAR(5);
  v_my_state_province_name VARCHAR(50);
  v_my_area_code          VARCHAR(4);
BEGIN

RAISE NOTICE 'Inserting purchasing.suppliers';

/* A Datum Corporation ----------------------------------------------------------------*/
SELECT city_id, city_name, state_province_code, state_province_name, area_code
  INTO v_my_city_id, v_my_city_name, v_my_state_province_code, v_my_state_province_name, v_my_area_code
  FROM dataloadsimulation.get_random_city();

v_bank := 'Woodgrove Bank ' || v_my_city_name;

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
  , dataloadsimulation.get_supplier_category_id('Novelty Goods Supplier')
  , dataloadsimulation.get_person_id('Reio Kabin')
  , dataloadsimulation.get_person_id('Oliver Kivi')
  , dataloadsimulation.get_delivery_method_id('Road Freight')
  , v_my_city_id, v_my_city_id
  , 'AA20384'
  , 'A Datum Corporation', v_bank, '356981', '8575824136', '25986'
  , 14, NULL
  , '(' || v_my_area_code || ') 555-0100', '(' || v_my_area_code || ') 555-0101'
  , 'http://www.adatum.com'
  , 'Suite 10', '183838 Southwest Boulevard', '46077', NULL
  , 'PO Box 1039', 'Surrey', '46077'
  , 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6));

/* Contoso, Ltd. ----------------------------------------------------------------------*/
SELECT city_id, city_name, state_province_code, state_province_name, area_code
  INTO v_my_city_id, v_my_city_name, v_my_state_province_code, v_my_state_province_name, v_my_area_code
  FROM dataloadsimulation.get_random_city();

v_bank := 'Woodgrove Bank ' || v_my_city_name;

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
  , dataloadsimulation.get_supplier_category_id('Novelty Goods Supplier')
  , dataloadsimulation.get_person_id('Hanna Mihhailov')
  , dataloadsimulation.get_person_id('Paulus Lippmaa')
  , dataloadsimulation.get_delivery_method_id('Refrigerated Road Freight')
  , v_my_city_id, v_my_city_id
  , 'B2084020'
  , 'Contoso Ltd', v_bank, '358698', '4587965215', '25868'
  , 7, NULL
  , '(' || v_my_area_code || ') 555-0100', '(' || v_my_area_code || ') 555-0101'
  , 'http://www.contoso.com'
  , 'Unit 2', '2934 Night Road', '98253', NULL
  , 'PO Box 1012', 'Jolimont', '98253'
  , 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6)
  );

/* Consolidated Messenger -------------------------------------------------------------*/
SELECT city_id, city_name, state_province_code, state_province_name, area_code
  INTO v_my_city_id, v_my_city_name, v_my_state_province_code, v_my_state_province_name, v_my_area_code
  FROM dataloadsimulation.get_random_city();

v_bank := 'Woodgrove Bank ' || v_my_city_name;

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
  , dataloadsimulation.get_supplier_category_id('Courier')
  , dataloadsimulation.get_person_id('Kerstin Parn')
  , dataloadsimulation.get_person_id('Helen Ahven')
  , dataloadsimulation.get_delivery_method_id('NULL')
  , v_my_city_id, v_my_city_id
  , '209340283'
  , 'Consolidated Messenger', v_bank, '354269', '3254872158', '45698'
  , 30, NULL
  , '(' || v_my_area_code || ') 555-0100', '(' || v_my_area_code || ') 555-0101'
  , 'http://www.consolidatedmessenger.com'
  , '', '894 Market Day Street', '94101', NULL
  , 'PO Box 1014', 'West Mont', '94101'
  , 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6)
  );

/* Fabrikam, Inc. ---------------------------------------------------------------------*/
SELECT city_id, city_name, state_province_code, state_province_name, area_code
  INTO v_my_city_id, v_my_city_name, v_my_state_province_code, v_my_state_province_name, v_my_area_code
  FROM dataloadsimulation.get_random_city();

v_bank := 'Woodgrove Bank ' || v_my_city_name;

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
  , dataloadsimulation.get_supplier_category_id('Clothing Supplier')
  , dataloadsimulation.get_person_id('Bill Lawson')
  , dataloadsimulation.get_person_id('Helen Moore')
  , dataloadsimulation.get_delivery_method_id('Road Freight')
  , v_my_city_id, v_my_city_id
  , '293092'
  , 'Fabrikam Inc', v_bank, '789568', '4125863879', '12546'
  , 30, NULL
  , '(' || v_my_area_code || ') 555-0104', '(' || v_my_area_code || ') 555-0108'
  , 'http://www.fabrikam.com'
  , 'Level 2', '393999 Woodberg Road', '40351', NULL
  , 'PO Box 301', 'Eaglemont', '40351'
  , 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6)
  );

/* Graphic Design Institute -----------------------------------------------------------*/
SELECT city_id, city_name, state_province_code, state_province_name, area_code
  INTO v_my_city_id, v_my_city_name, v_my_state_province_code, v_my_state_province_name, v_my_area_code
  FROM dataloadsimulation.get_random_city();

v_bank := 'Woodgrove Bank ' || v_my_city_name;

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
  , dataloadsimulation.get_supplier_category_id('Novelty Goods Supplier')
  , dataloadsimulation.get_person_id('Penny Buck')
  , dataloadsimulation.get_person_id('Donna Smith')
  , dataloadsimulation.get_delivery_method_id('Refrigerated Air Freight')
  , v_my_city_id, v_my_city_id
  , '08803922'
  , 'Graphic Design Institute', v_bank, '563215', '1025869354', '32587'
  , 14, NULL
  , '(' || v_my_area_code || ') 555-0105', '(' || v_my_area_code || ') 555-0106'
  , 'http://www.graphicdesigninstitute.com'
  , '', '45th Street', '64847', NULL
  , 'PO Box 393', 'Willow', '64847'
  , 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6)
  );

/* Humongous Insurance ----------------------------------------------------------------*/
SELECT city_id, city_name, state_province_code, state_province_name, area_code
  INTO v_my_city_id, v_my_city_name, v_my_state_province_code, v_my_state_province_name, v_my_area_code
  FROM dataloadsimulation.get_random_city();

v_bank := 'Woodgrove Bank ' || v_my_city_name;

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
  , dataloadsimulation.get_supplier_category_id('Insurance Services Supplier')
  , dataloadsimulation.get_person_id('Madelaine  Cartier')
  , dataloadsimulation.get_person_id('Annette Talon')
  , dataloadsimulation.get_delivery_method_id('NULL')
  , v_my_city_id, v_my_city_id
  , '082420938'
  , 'Humongous Insurance', v_bank, '325001', '2569874521', '32569'
  , 14, NULL
  , '(' || v_my_area_code || ') 555-0105', '(' || v_my_area_code || ') 555-0100'
  , 'http://www.humongousinsurance.com'
  , '', '9893 Mount Norris Road', '37770', NULL
  , 'PO Box 94829', 'Boxville', '37770'
  , 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6)
  );

/* Litware, Inc. ----------------------------------------------------------------------*/
SELECT city_id, city_name, state_province_code, state_province_name, area_code
  INTO v_my_city_id, v_my_city_name, v_my_state_province_code, v_my_state_province_name, v_my_area_code
  FROM dataloadsimulation.get_random_city();

v_bank := 'Woodgrove Bank ' || v_my_city_name;

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
  , dataloadsimulation.get_supplier_category_id('Packaging Supplier')
  , dataloadsimulation.get_person_id('Elias Myllari')
  , dataloadsimulation.get_person_id('Vilma Niva')
  , dataloadsimulation.get_delivery_method_id('Courier')
  , v_my_city_id, v_my_city_id
  , 'BC0280982'
  , 'Litware Inc', v_bank, '358769', '3256896325', '21445'
  , 30, NULL
  , '(' || v_my_area_code || ') 555-0108', '(' || v_my_area_code || ') 555-0104'
  , 'http://www.litwareinc.com'
  , 'Level 3', '19 Le Church Street', '95245', NULL
  , 'PO Box 20290', 'Jackson', '95245'
  , 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6)
  );

/* Lucerne Publishing -----------------------------------------------------------------*/
SELECT city_id, city_name, state_province_code, state_province_name, area_code
  INTO v_my_city_id, v_my_city_name, v_my_state_province_code, v_my_state_province_name, v_my_area_code
  FROM dataloadsimulation.get_random_city();

v_bank := 'Woodgrove Bank ' || v_my_city_name;

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
  , dataloadsimulation.get_supplier_category_id('Novelty Goods Supplier')
  , dataloadsimulation.get_person_id('Prem Prabhu')
  , dataloadsimulation.get_person_id('Sunita Jadhav')
  , dataloadsimulation.get_delivery_method_id('Refrigerated Air Freight')
  , v_my_city_id, v_my_city_id
  , 'JQ082304802'
  , 'Lucerne Publishing', v_bank, '654789', '3254123658', '21569'
  , 30, NULL
  , '(' || v_my_area_code || ') 555-0103', '(' || v_my_area_code || ') 555-0105'
  , 'http://www.lucernepublishing.com'
  , 'Suite 34', '949482 Miller Boulevard', '37659', NULL
  , 'PO Box 8747', 'Westerfold', '37659'
  , 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6)
  );

/* Nod Publishers ---------------------------------------------------------------------*/
SELECT city_id, city_name, state_province_code, state_province_name, area_code
  INTO v_my_city_id, v_my_city_name, v_my_state_province_code, v_my_state_province_name, v_my_area_code
  FROM dataloadsimulation.get_random_city();

v_bank := 'Woodgrove Bank ' || v_my_city_name;

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
  , dataloadsimulation.get_supplier_category_id('Novelty Goods Supplier')
  , dataloadsimulation.get_person_id('Marcos Costa')
  , dataloadsimulation.get_person_id('Matheus Oliveira')
  , dataloadsimulation.get_delivery_method_id('Refrigerated Air Freight')
  , v_my_city_id, v_my_city_id
  , 'GL08029802'
  , 'Nod Publishers', v_bank, '365985', '2021545878', '48758'
  , 7, 'Marcos is not in on Mondays'
  , '(' || v_my_area_code || ') 555-0100', '(' || v_my_area_code || ') 555-0101'
  , 'http://www.nodpublishers.com'
  , 'Level 1', '389 King Street', '27906', NULL
  , 'PO Box 3390', 'Anderson', '27906'
  , 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6)
  );

/* Northwind Electric Cars ------------------------------------------------------------*/
SELECT city_id, city_name, state_province_code, state_province_name, area_code
  INTO v_my_city_id, v_my_city_name, v_my_state_province_code, v_my_state_province_name, v_my_area_code
  FROM dataloadsimulation.get_random_city();

v_bank := 'Woodgrove Bank ' || v_my_city_name;

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
  , dataloadsimulation.get_supplier_category_id('Toy Supplier')
  , dataloadsimulation.get_person_id('Eliza Soderberg')
  , dataloadsimulation.get_person_id('Sara Karlsson')
  , dataloadsimulation.get_delivery_method_id('Air Freight')
  , v_my_city_id, v_my_city_id
  , 'ML0300202'
  , 'Northwind Electric Cars', v_bank, '325447', '3258786987', '36214'
  , 30, NULL
  , '(' || v_my_area_code || ') 555-0105', '(' || v_my_area_code || ') 555-0104'
  , 'http://www.northwindelectriccars.com'
  , '', '440 New Road', '07860', NULL
  , 'PO Box 30920', 'Arlington', '07860'
  , 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6)
  );

/* Trey Research ----------------------------------------------------------------------*/
SELECT city_id, city_name, state_province_code, state_province_name, area_code
  INTO v_my_city_id, v_my_city_name, v_my_state_province_code, v_my_state_province_name, v_my_area_code
  FROM dataloadsimulation.get_random_city();

v_bank := 'Woodgrove Bank ' || v_my_city_name;

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
  , dataloadsimulation.get_supplier_category_id('Marketing Services Supplier')
  , dataloadsimulation.get_person_id('Donald Jones')
  , dataloadsimulation.get_person_id('Sharon Graham')
  , dataloadsimulation.get_delivery_method_id('NULL')
  , v_my_city_id, v_my_city_id
  , '082304822'
  , 'Trey Research', v_bank, '658968', '1254785321', '56958'
  , 7, NULL
  , '(' || v_my_area_code || ') 555-0103', '(' || v_my_area_code || ') 555-0101'
  , 'http://www.treyresearch.net'
  , 'Level 43', '9401 Polar Avenue', '57543', NULL
  , 'PO  Box 595', 'Port Fairy', '57543'
  , 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6)
  );

/* The Phone Company ------------------------------------------------------------------*/
SELECT city_id, city_name, state_province_code, state_province_name, area_code
  INTO v_my_city_id, v_my_city_name, v_my_state_province_code, v_my_state_province_name, v_my_area_code
  FROM dataloadsimulation.get_random_city();

v_bank := 'Woodgrove Bank ' || v_my_city_name;

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
  , dataloadsimulation.get_supplier_category_id('Novelty Goods Supplier')
  , dataloadsimulation.get_person_id('Hai Dam')
  , dataloadsimulation.get_person_id('Thanh Dinh')
  , dataloadsimulation.get_delivery_method_id('Road Freight')
  , v_my_city_id, v_my_city_id
  , '237408032'
  , 'The Phone Company', v_bank, '214568', '7896236589', '25478'
  , 30, NULL
  , '(' || v_my_area_code || ') 555-0105', '(' || v_my_area_code || ') 555-0105'
  , 'http://www.thephone-company.com'
  , 'Level 83', '339 Toorak Road', '56732', NULL
  , 'PO Box 3837', 'Ferny Wood', '56732'
  , 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6)
  );

/* Woodgrove Bank ---------------------------------------------------------------------*/
SELECT city_id, city_name, state_province_code, state_province_name, area_code
  INTO v_my_city_id, v_my_city_name, v_my_state_province_code, v_my_state_province_name, v_my_area_code
  FROM dataloadsimulation.get_random_city();

v_bank := 'Woodgrove Bank ' || v_my_city_name;

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
  , dataloadsimulation.get_supplier_category_id('Financial Services Supplier')
  , dataloadsimulation.get_person_id('Hubert Helms')
  , dataloadsimulation.get_person_id('Donald Small')
  , dataloadsimulation.get_delivery_method_id('NULL')
  , v_my_city_id, v_my_city_id
  , '028034202'
  , 'Woodgrove Bank', v_bank, '325698', '2147825698', '65893'
  , 7, 'Only speak to Donald if Hubert really is not available'
  , '(' || v_my_area_code || ') 555-0103', '(' || v_my_area_code || ') 555-0107'
  , 'http://www.woodgrovebank.com'
  , 'Level 3', '8488 Vienna Boulevard', '94101', NULL
  , 'PO Box 2390', 'Canterbury', '94101'
  , 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6)
  );

UPDATE purchasing.suppliers AS s
   SET DeliveryLocation = c.Location
     , ValidFrom = '2020-01-01 00:00:00'::TIMESTAMP(6) + (CEIL(RANDOM() * 5) * INTERVAL '1 minute')
  FROM application.cities AS c
 WHERE s.DeliveryCityID = c.CityID;

END;
$$;
