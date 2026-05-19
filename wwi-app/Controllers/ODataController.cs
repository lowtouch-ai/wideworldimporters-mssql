using Dapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using Npgsql;
using System;
using System.IO;
using System.Security.Claims;
using System.Threading.Tasks;

namespace wwi_app.Controllers
{
    public partial class ODataController : Controller
    {
        private readonly NpgsqlDataSource _db;

        public ODataController(NpgsqlDataSource db)
        {
            _db = db;
        }

        private int CurrentUserId() =>
            Convert.ToInt32(User.FindFirst(ClaimTypes.Sid)?.Value ?? "0");

        private async Task WriteTableJson(string sql, object? param = null)
        {
            await using var conn = await _db.OpenConnectionAsync();
            var rows = await conn.QueryAsync(sql, param);
            Response.ContentType = "application/json";
            await Response.WriteAsync(JsonConvert.SerializeObject(new { value = rows }));
        }

        private async Task ExecFunction(string sql, object param)
        {
            await using var conn = await _db.OpenConnectionAsync();
            await conn.ExecuteAsync(sql, param);
        }

        // ── SalesOrders ──────────────────────────────────────────────────────────

        [HttpGet]
        public async Task SalesOrders(int? id)
        {
            if (id.HasValue)
                await WriteTableJson("SELECT OrderID,OrderDate,CustomerPurchaseOrderNumber,ExpectedDeliveryDate,PickingCompletedWhen,CustomerID,CustomerName,PhoneNumber,FaxNumber,WebsiteURL,DeliveryLocation,SalesPerson,SalesPersonPhone,SalesPersonEmail FROM webapi.sales_orders WHERE OrderID = @id", new { id });
            else
                await WriteTableJson("SELECT OrderID,OrderDate,CustomerPurchaseOrderNumber,ExpectedDeliveryDate,PickingCompletedWhen,CustomerID,CustomerName,PhoneNumber,FaxNumber,WebsiteURL,DeliveryLocation,SalesPerson,SalesPersonPhone,SalesPersonEmail FROM webapi.sales_orders");
        }

        [Authorize, HttpPut]
        public async Task SalesOrders(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.update_sales_order_from_json(@json, @eid, @uid)", new { json, eid = id, uid = CurrentUserId() });
        }

        [Authorize, HttpPost]
        public async Task SalesOrders()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.insert_sales_orders_from_json(@json, @uid)", new { json, uid = CurrentUserId() });
        }

        [Authorize, HttpDelete]
        public async Task SalesOrders(int id) =>
            await ExecFunction("SELECT webapi.delete_sales_order(@id)", new { id });

        // ── SalesOrderLines ──────────────────────────────────────────────────────

        [HttpGet]
        public async Task SalesOrderLines(int? id)
        {
            if (id.HasValue)
                await WriteTableJson("SELECT OrderLineID,OrderID,Description,Quantity,UnitPrice,TaxRate,ProductName,Brand,Size,ColorName,PackageTypeName,PickingCompletedWhen FROM webapi.sales_order_lines WHERE OrderLineID = @id", new { id });
            else
                await WriteTableJson("SELECT OrderLineID,OrderID,Description,Quantity,UnitPrice,TaxRate,ProductName,Brand,Size,ColorName,PackageTypeName,PickingCompletedWhen FROM webapi.sales_order_lines");
        }

        [Authorize, HttpPut]
        public async Task SalesOrderLines(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.update_sales_order_line_from_json(@json, @eid, @uid)", new { json, eid = id, uid = CurrentUserId() });
        }

        [Authorize, HttpPost]
        public async Task SalesOrderLines()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.insert_sales_order_lines_from_json(@json, @uid)", new { json, uid = CurrentUserId() });
        }

        [Authorize, HttpDelete]
        public async Task SalesOrderLines(int id) =>
            await ExecFunction("SELECT webapi.delete_sales_order_line(@id)", new { id });

        // ── PurchaseOrders ───────────────────────────────────────────────────────

        [HttpGet]
        public async Task PurchaseOrders(int? id)
        {
            if (id.HasValue)
                await WriteTableJson("SELECT PurchaseOrderID,OrderDate,ExpectedDeliveryDate,SupplierReference,IsOrderFinalized,DeliveryMethodName,ContactName,ContactPhone,ContactFax,ContactEmail,SupplierID FROM webapi.purchase_orders WHERE PurchaseOrderID = @id", new { id });
            else
                await WriteTableJson("SELECT PurchaseOrderID,OrderDate,ExpectedDeliveryDate,SupplierReference,IsOrderFinalized,DeliveryMethodName,ContactName,ContactPhone,ContactFax,ContactEmail,SupplierID FROM webapi.purchase_orders");
        }

        [Authorize, HttpPut]
        public async Task PurchaseOrders(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.update_purchase_order_from_json(@json, @eid, @uid)", new { json, eid = id, uid = CurrentUserId() });
        }

        [Authorize, HttpPost]
        public async Task PurchaseOrders()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.insert_purchase_orders_from_json(@json, @uid)", new { json, uid = CurrentUserId() });
        }

        [Authorize, HttpDelete]
        public async Task PurchaseOrders(int id) =>
            await ExecFunction("SELECT webapi.delete_purchase_order(@id)", new { id });

        // ── PurchaseOrderLines ───────────────────────────────────────────────────

        [HttpGet]
        public async Task PurchaseOrderLines(int? id)
        {
            if (id.HasValue)
                await WriteTableJson("SELECT PurchaseOrderLineID,PurchaseOrderID,Description,IsOrderLineFinalized,ProductName,Brand,Size,ColorName,PackageTypeName,OrderedOuters,ReceivedOuters,ExpectedUnitPricePerOuter FROM webapi.purchase_order_lines WHERE PurchaseOrderLineID = @id", new { id });
            else
                await WriteTableJson("SELECT PurchaseOrderLineID,PurchaseOrderID,Description,IsOrderLineFinalized,ProductName,Brand,Size,ColorName,PackageTypeName,OrderedOuters,ReceivedOuters,ExpectedUnitPricePerOuter FROM webapi.purchase_order_lines");
        }

        [Authorize, HttpPut]
        public async Task PurchaseOrderLines(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.update_purchase_order_line_from_json(@json, @eid, @uid)", new { json, eid = id, uid = CurrentUserId() });
        }

        [Authorize, HttpPost]
        public async Task PurchaseOrderLines()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.insert_purchase_order_lines_from_json(@json, @uid)", new { json, uid = CurrentUserId() });
        }

        [Authorize, HttpDelete]
        public async Task PurchaseOrderLines(int id) =>
            await ExecFunction("SELECT webapi.delete_purchase_order_line(@id)", new { id });

        // ── Invoices ─────────────────────────────────────────────────────────────

        [HttpGet]
        public async Task Invoices(int? id)
        {
            if (id.HasValue)
                await WriteTableJson("SELECT InvoiceID,InvoiceDate,CustomerPurchaseOrderNumber,IsCreditNote,TotalDryItems,TotalChillerItems,DeliveryRun,RunPosition,ReturnedDeliveryData,ConfirmedDeliveryTime,ConfirmedReceivedBy,CustomerName,SalesPersonName,ContactName,ContactPhone,ContactEmail,SalesPersonEmail,DeliveryMethodName,CustomerID,OrderID,DeliveryMethodID,ContactPersonID,AccountsPersonID,SalespersonPersonID,PackedByPersonID FROM webapi.invoices WHERE InvoiceID = @id", new { id });
            else
                await WriteTableJson("SELECT InvoiceID,InvoiceDate,CustomerPurchaseOrderNumber,IsCreditNote,TotalDryItems,TotalChillerItems,DeliveryRun,RunPosition,ReturnedDeliveryData,ConfirmedDeliveryTime,ConfirmedReceivedBy,CustomerName,SalesPersonName,ContactName,ContactPhone,ContactEmail,SalesPersonEmail,DeliveryMethodName,CustomerID,OrderID,DeliveryMethodID,ContactPersonID,AccountsPersonID,SalespersonPersonID,PackedByPersonID FROM webapi.invoices");
        }

        [Authorize, HttpPut]
        public async Task Invoices(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.update_invoice_from_json(@json, @eid, @uid)", new { json, eid = id, uid = CurrentUserId() });
        }

        [Authorize, HttpPost]
        public async Task Invoices()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.insert_invoices_from_json(@json, @uid)", new { json, uid = CurrentUserId() });
        }

        [Authorize, HttpDelete]
        public async Task Invoices(int id) =>
            await ExecFunction("SELECT webapi.delete_invoice(@id)", new { id });

        // ── SpecialDeals ─────────────────────────────────────────────────────────

        [HttpGet]
        public async Task SpecialDeals(int? id)
        {
            if (id.HasValue)
                await WriteTableJson("SELECT SpecialDealID,DealDescription,StartDate,EndDate,DiscountAmount,DiscountPercentage,UnitPrice,StockItemName,Brand,Size,CustomerName,BuyingGroupName,CustomerCategoryName,StockItemID,CustomerID,BuyingGroupID,CustomerCategoryID,StockGroupID FROM webapi.special_deals WHERE SpecialDealID = @id", new { id });
            else
                await WriteTableJson("SELECT SpecialDealID,DealDescription,StartDate,EndDate,DiscountAmount,DiscountPercentage,UnitPrice,StockItemName,Brand,Size,CustomerName,BuyingGroupName,CustomerCategoryName,StockItemID,CustomerID,BuyingGroupID,CustomerCategoryID,StockGroupID FROM webapi.special_deals");
        }

        [Authorize, HttpPut]
        public async Task SpecialDeals(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.update_special_deal_from_json(@json, @eid, @uid)", new { json, eid = id, uid = CurrentUserId() });
        }

        [Authorize, HttpPost]
        public async Task SpecialDeals()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.insert_special_deals_from_json(@json, @uid)", new { json, uid = CurrentUserId() });
        }

        [Authorize, HttpDelete]
        public async Task SpecialDeals(int id) =>
            await ExecFunction("SELECT webapi.delete_special_deal(@id)", new { id });

        // ── CustomerTransactions ─────────────────────────────────────────────────

        [HttpGet]
        public async Task CustomerTransactions(int? id)
        {
            if (id.HasValue)
                await WriteTableJson("SELECT CustomerTransactionID,TransactionDate,AmountExcludingTax,TaxAmount,TransactionAmount,OutstandingBalance,FinalizationDate,IsFinalized,CustomerName,TransactionTypeName,InvoiceDate,CustomerPurchaseOrderNumber,PaymentMethodName,CustomerID,TransactionTypeID,InvoiceID,PaymentMethodID FROM webapi.customer_transactions WHERE CustomerTransactionID = @id", new { id });
            else
                await WriteTableJson("SELECT CustomerTransactionID,TransactionDate,AmountExcludingTax,TaxAmount,TransactionAmount,OutstandingBalance,FinalizationDate,IsFinalized,CustomerName,TransactionTypeName,InvoiceDate,CustomerPurchaseOrderNumber,PaymentMethodName,CustomerID,TransactionTypeID,InvoiceID,PaymentMethodID FROM webapi.customer_transactions");
        }

        [Authorize, HttpPut]
        public async Task CustomerTransactions(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.update_customer_transaction_from_json(@json, @eid, @uid)", new { json, eid = id, uid = CurrentUserId() });
        }

        [Authorize, HttpPost]
        public async Task CustomerTransactions()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.insert_customer_transactions_from_json(@json, @uid)", new { json, uid = CurrentUserId() });
        }

        [Authorize, HttpDelete]
        public async Task CustomerTransactions(int id) =>
            await ExecFunction("SELECT webapi.delete_customer_transaction(@id)", new { id });

        // ── SupplierTransactions ─────────────────────────────────────────────────

        [HttpGet]
        public async Task SupplierTransactions(int? id)
        {
            if (id.HasValue)
                await WriteTableJson("SELECT SupplierTransactionID,TransactionDate,AmountExcludingTax,TaxAmount,TransactionAmount,OutstandingBalance,FinalizationDate,IsFinalized,SupplierName,TransactionTypeName,PaymentMethodName,SupplierID,TransactionTypeID,PurchaseOrderID,PaymentMethodID,OrderDate,IsOrderFinalized,ExpectedDeliveryDate,SupplierReference FROM webapi.supplier_transactions WHERE SupplierTransactionID = @id", new { id });
            else
                await WriteTableJson("SELECT SupplierTransactionID,TransactionDate,AmountExcludingTax,TaxAmount,TransactionAmount,OutstandingBalance,FinalizationDate,IsFinalized,SupplierName,TransactionTypeName,PaymentMethodName,SupplierID,TransactionTypeID,PurchaseOrderID,PaymentMethodID,OrderDate,IsOrderFinalized,ExpectedDeliveryDate,SupplierReference FROM webapi.supplier_transactions");
        }

        [Authorize, HttpPut]
        public async Task SupplierTransactions(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.update_supplier_transaction_from_json(@json, @eid, @uid)", new { json, eid = id, uid = CurrentUserId() });
        }

        [Authorize, HttpPost]
        public async Task SupplierTransactions()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.insert_supplier_transactions_from_json(@json, @uid)", new { json, uid = CurrentUserId() });
        }

        [Authorize, HttpDelete]
        public async Task SupplierTransactions(int id) =>
            await ExecFunction("SELECT webapi.delete_supplier_transaction(@id)", new { id });

        // ── Customers ────────────────────────────────────────────────────────────

        [HttpGet]
        public async Task Customers(int? id)
        {
            if (id.HasValue)
                await WriteTableJson("SELECT CustomerID,CustomerName,AccountOpenedDate,CustomerCategoryName,PrimaryContact,AlternateContact,PhoneNumber,FaxNumber,WebsiteURL,PostalAddressLine1,PostalAddressLine2,PostalCity,PostalCityID,PostalPostalCode,CreditLimit,IsOnCreditHold,IsStatementSent,PaymentDays,RunPosition,StandardDiscountPercentage,BuyingGroupName,DeliveryLocation,BuyingGroupID,BillToCustomerID,CustomerCategoryID,PrimaryContactPersonID,AlternateContactPersonID FROM webapi.customers WHERE CustomerID = @id", new { id });
            else
                await WriteTableJson("SELECT CustomerID,CustomerName,AccountOpenedDate,CustomerCategoryName,PrimaryContact,AlternateContact,PhoneNumber,FaxNumber,WebsiteURL,PostalAddressLine1,PostalAddressLine2,PostalCity,PostalCityID,PostalPostalCode,CreditLimit,IsOnCreditHold,IsStatementSent,PaymentDays,RunPosition,StandardDiscountPercentage,BuyingGroupName,DeliveryLocation,BuyingGroupID,BillToCustomerID,CustomerCategoryID,PrimaryContactPersonID,AlternateContactPersonID FROM webapi.customers");
        }

        [Authorize, HttpPut]
        public async Task Customers(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.update_customer_from_json(@json, @eid, @uid)", new { json, eid = id, uid = CurrentUserId() });
        }

        [Authorize, HttpPost]
        public async Task Customers()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.insert_customers_from_json(@json, @uid)", new { json, uid = CurrentUserId() });
        }

        [Authorize, HttpDelete]
        public async Task Customers(int id) =>
            await ExecFunction("SELECT webapi.delete_customer(@id)", new { id });

        // ── Suppliers ────────────────────────────────────────────────────────────

        [HttpGet]
        public async Task Suppliers(int? id)
        {
            if (id.HasValue)
                await WriteTableJson("SELECT SupplierID,SupplierName,SupplierCategoryName,PrimaryContact,AlternateContact,PhoneNumber,FaxNumber,WebsiteURL,SupplierReference,DeliveryLocation,BankAccountName,BankAccountBranch,BankAccountCode,BankAccountNumber,BankInternationalCode,PostalAddressLine1,PostalAddressLine2,PostalPostalCode,PaymentDays,SupplierCategoryID FROM webapi.suppliers WHERE SupplierID = @id", new { id });
            else
                await WriteTableJson("SELECT SupplierID,SupplierName,SupplierCategoryName,PrimaryContact,AlternateContact,PhoneNumber,FaxNumber,WebsiteURL,SupplierReference,DeliveryLocation,BankAccountName,BankAccountBranch,BankAccountCode,BankAccountNumber,BankInternationalCode,PostalAddressLine1,PostalAddressLine2,PostalPostalCode,PaymentDays,SupplierCategoryID FROM webapi.suppliers");
        }

        [Authorize, HttpPut]
        public async Task Suppliers(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.update_supplier_from_json(@json, @eid, @uid)", new { json, eid = id, uid = CurrentUserId() });
        }

        [Authorize, HttpPost]
        public async Task Suppliers()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.insert_suppliers_from_json(@json, @uid)", new { json, uid = CurrentUserId() });
        }

        [Authorize, HttpDelete]
        public async Task Suppliers(int id) =>
            await ExecFunction("SELECT webapi.delete_supplier(@id)", new { id });

        // ── Countries ────────────────────────────────────────────────────────────

        [HttpGet]
        public async Task Countries(int? id)
        {
            if (id.HasValue)
                await WriteTableJson("SELECT CountryID,CountryName,FormalName,IsoAlpha3Code,IsoNumericCode,CountryType,LatestRecordedPopulation,Continent,Region,Subregion FROM webapi.countries WHERE CountryID = @id", new { id });
            else
                await WriteTableJson("SELECT CountryID,CountryName,FormalName,IsoAlpha3Code,IsoNumericCode,CountryType,LatestRecordedPopulation,Continent,Region,Subregion FROM webapi.countries");
        }

        [Authorize, HttpPut]
        public async Task Countries(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.update_country_from_json(@json, @eid, @uid)", new { json, eid = id, uid = CurrentUserId() });
        }

        [Authorize, HttpPost]
        public async Task Countries()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.insert_countries_from_json(@json, @uid)", new { json, uid = CurrentUserId() });
        }

        [Authorize, HttpDelete]
        public async Task Countries(int id) =>
            await ExecFunction("SELECT webapi.delete_country(@id)", new { id });

        // ── Cities ───────────────────────────────────────────────────────────────

        [HttpGet]
        public async Task Cities(int? id)
        {
            if (id.HasValue)
                await WriteTableJson("SELECT CityID,CityName,StateProvinceID,LatestRecordedPopulation FROM webapi.cities WHERE CityID = @id", new { id });
            else
                await WriteTableJson("SELECT CityID,CityName,StateProvinceID,LatestRecordedPopulation FROM webapi.cities");
        }

        [Authorize, HttpPut]
        public async Task Cities(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.update_city_from_json(@json, @eid, @uid)", new { json, eid = id, uid = CurrentUserId() });
        }

        [Authorize, HttpPost]
        public async Task Cities()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.insert_cities_from_json(@json, @uid)", new { json, uid = CurrentUserId() });
        }

        [Authorize, HttpDelete]
        public async Task Cities(int id) =>
            await ExecFunction("SELECT webapi.delete_city(@id)", new { id });

        // ── StateProvinces ───────────────────────────────────────────────────────

        [HttpGet]
        public async Task StateProvinces(int? id)
        {
            if (id.HasValue)
                await WriteTableJson("SELECT StateProvinceID,StateProvinceCode,StateProvinceName,CountryID,SalesTerritory,LatestRecordedPopulation FROM webapi.state_provinces WHERE StateProvinceID = @id", new { id });
            else
                await WriteTableJson("SELECT StateProvinceID,StateProvinceCode,StateProvinceName,CountryID,SalesTerritory,LatestRecordedPopulation FROM webapi.state_provinces");
        }

        [Authorize, HttpPut]
        public async Task StateProvinces(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.update_state_province_from_json(@json, @eid, @uid)", new { json, eid = id, uid = CurrentUserId() });
        }

        [Authorize, HttpPost]
        public async Task StateProvinces()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.insert_state_provinces_from_json(@json, @uid)", new { json, uid = CurrentUserId() });
        }

        [Authorize, HttpDelete]
        public async Task StateProvinces(int id) =>
            await ExecFunction("SELECT webapi.delete_state_province(@id)", new { id });

        // ── StockItems ───────────────────────────────────────────────────────────

        [HttpGet]
        public async Task StockItems(int? id)
        {
            if (id.HasValue)
                await WriteTableJson("SELECT StockItemID,StockItemName,SupplierName,SupplierReference,ColorName,OuterPackage,UnitPackage,Brand,Size,LeadTimeDays,QuantityPerOuter,IsChillerStock,Barcode,TaxRate,UnitPrice,RecommendedRetailPrice,TypicalWeightPerUnit,MarketingComments,InternalComments,CustomFields,QuantityOnHand,BinLocation,LastStocktakeQuantity,LastCostPrice,ReorderLevel,TargetStockLevel,SupplierID,ColorID,UnitPackageID,OuterPackageID FROM webapi.stock_items WHERE StockItemID = @id", new { id });
            else
                await WriteTableJson("SELECT StockItemID,StockItemName,SupplierName,SupplierReference,ColorName,OuterPackage,UnitPackage,Brand,Size,LeadTimeDays,QuantityPerOuter,IsChillerStock,Barcode,TaxRate,UnitPrice,RecommendedRetailPrice,TypicalWeightPerUnit,MarketingComments,InternalComments,CustomFields,QuantityOnHand,BinLocation,LastStocktakeQuantity,LastCostPrice,ReorderLevel,TargetStockLevel,SupplierID,ColorID,UnitPackageID,OuterPackageID FROM webapi.stock_items");
        }

        [Authorize, HttpPut]
        public async Task StockItems(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.update_stock_item_from_json(@json, @eid, @uid)", new { json, eid = id, uid = CurrentUserId() });
        }

        [Authorize, HttpPost]
        public async Task StockItems()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.insert_stock_items_from_json(@json, @uid)", new { json, uid = CurrentUserId() });
        }

        [Authorize, HttpDelete]
        public async Task StockItems(int id) =>
            await ExecFunction("SELECT webapi.delete_stock_item(@id)", new { id });

        // ── PackageTypes ─────────────────────────────────────────────────────────

        [HttpGet]
        public async Task PackageTypes(int? id)
        {
            if (id.HasValue)
                await WriteTableJson("SELECT PackageTypeID,PackageTypeName FROM webapi.package_types WHERE PackageTypeID = @id", new { id });
            else
                await WriteTableJson("SELECT PackageTypeID,PackageTypeName FROM webapi.package_types");
        }

        [Authorize, HttpPut]
        public async Task PackageTypes(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.update_package_type_from_json(@json, @eid, @uid)", new { json, eid = id, uid = CurrentUserId() });
        }

        [Authorize, HttpPost]
        public async Task PackageTypes()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.insert_package_types_from_json(@json, @uid)", new { json, uid = CurrentUserId() });
        }

        [Authorize, HttpDelete]
        public async Task PackageTypes(int id) =>
            await ExecFunction("SELECT webapi.delete_package_type(@id)", new { id });

        // ── Colors ───────────────────────────────────────────────────────────────

        [HttpGet]
        public async Task Colors(int? id)
        {
            if (id.HasValue)
                await WriteTableJson("SELECT ColorID,ColorName FROM webapi.colors WHERE ColorID = @id", new { id });
            else
                await WriteTableJson("SELECT ColorID,ColorName FROM webapi.colors");
        }

        [Authorize, HttpPut]
        public async Task Colors(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.update_color_from_json(@json, @eid, @uid)", new { json, eid = id, uid = CurrentUserId() });
        }

        [Authorize, HttpPost]
        public async Task Colors()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.insert_colors_from_json(@json, @uid)", new { json, uid = CurrentUserId() });
        }

        [Authorize, HttpDelete]
        public async Task Colors(int id) =>
            await ExecFunction("SELECT webapi.delete_color(@id)", new { id });

        // ── StockGroups ──────────────────────────────────────────────────────────

        [HttpGet]
        public async Task StockGroups(int? id)
        {
            if (id.HasValue)
                await WriteTableJson("SELECT StockGroupID,StockGroupName FROM webapi.stock_groups WHERE StockGroupID = @id", new { id });
            else
                await WriteTableJson("SELECT StockGroupID,StockGroupName FROM webapi.stock_groups");
        }

        [Authorize, HttpPut]
        public async Task StockGroups(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.update_stock_group_from_json(@json, @eid, @uid)", new { json, eid = id, uid = CurrentUserId() });
        }

        [Authorize, HttpPost]
        public async Task StockGroups()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.insert_stock_groups_from_json(@json, @uid)", new { json, uid = CurrentUserId() });
        }

        [Authorize, HttpDelete]
        public async Task StockGroups(int id) =>
            await ExecFunction("SELECT webapi.delete_stock_group(@id)", new { id });

        // ── BuyingGroups ─────────────────────────────────────────────────────────

        [HttpGet]
        public async Task BuyingGroups(int? id)
        {
            if (id.HasValue)
                await WriteTableJson("SELECT BuyingGroupID,BuyingGroupName FROM webapi.buying_groups WHERE BuyingGroupID = @id", new { id });
            else
                await WriteTableJson("SELECT BuyingGroupID,BuyingGroupName FROM webapi.buying_groups");
        }

        [Authorize, HttpPut]
        public async Task BuyingGroups(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.update_buying_group_from_json(@json, @eid, @uid)", new { json, eid = id, uid = CurrentUserId() });
        }

        [Authorize, HttpPost]
        public async Task BuyingGroups()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.insert_buying_groups_from_json(@json, @uid)", new { json, uid = CurrentUserId() });
        }

        [Authorize, HttpDelete]
        public async Task BuyingGroups(int id) =>
            await ExecFunction("SELECT webapi.delete_buying_group(@id)", new { id });

        // ── CustomerCategories ───────────────────────────────────────────────────

        [HttpGet]
        public async Task CustomerCategories(int? id)
        {
            if (id.HasValue)
                await WriteTableJson("SELECT CustomerCategoryID,CustomerCategoryName FROM webapi.customer_categories WHERE CustomerCategoryID = @id", new { id });
            else
                await WriteTableJson("SELECT CustomerCategoryID,CustomerCategoryName FROM webapi.customer_categories");
        }

        [Authorize, HttpPut]
        public async Task CustomerCategories(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.update_customer_category_from_json(@json, @eid, @uid)", new { json, eid = id, uid = CurrentUserId() });
        }

        [Authorize, HttpPost]
        public async Task CustomerCategories()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.insert_customer_categories_from_json(@json, @uid)", new { json, uid = CurrentUserId() });
        }

        [Authorize, HttpDelete]
        public async Task CustomerCategories(int id) =>
            await ExecFunction("SELECT webapi.delete_customer_category(@id)", new { id });

        // ── SupplierCategories ───────────────────────────────────────────────────

        [HttpGet]
        public async Task SupplierCategories(int? id)
        {
            if (id.HasValue)
                await WriteTableJson("SELECT SupplierCategoryID,SupplierCategoryName FROM webapi.supplier_categories WHERE SupplierCategoryID = @id", new { id });
            else
                await WriteTableJson("SELECT SupplierCategoryID,SupplierCategoryName FROM webapi.supplier_categories");
        }

        [Authorize, HttpPut]
        public async Task SupplierCategories(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.update_supplier_category_from_json(@json, @eid, @uid)", new { json, eid = id, uid = CurrentUserId() });
        }

        [Authorize, HttpPost]
        public async Task SupplierCategories()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.insert_supplier_categories_from_json(@json, @uid)", new { json, uid = CurrentUserId() });
        }

        [Authorize, HttpDelete]
        public async Task SupplierCategories(int id) =>
            await ExecFunction("SELECT webapi.delete_supplier_category(@id)", new { id });

        // ── TransactionTypes ─────────────────────────────────────────────────────

        [HttpGet]
        public async Task TransactionTypes(int? id)
        {
            if (id.HasValue)
                await WriteTableJson("SELECT TransactionTypeID,TransactionTypeName FROM webapi.transaction_types WHERE TransactionTypeID = @id", new { id });
            else
                await WriteTableJson("SELECT TransactionTypeID,TransactionTypeName FROM webapi.transaction_types");
        }

        [Authorize, HttpPut]
        public async Task TransactionTypes(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.update_transaction_type_from_json(@json, @eid, @uid)", new { json, eid = id, uid = CurrentUserId() });
        }

        [Authorize, HttpPost]
        public async Task TransactionTypes()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.insert_transaction_types_from_json(@json, @uid)", new { json, uid = CurrentUserId() });
        }

        [Authorize, HttpDelete]
        public async Task TransactionTypes(int id) =>
            await ExecFunction("SELECT webapi.delete_transaction_type(@id)", new { id });

        // ── PaymentMethods ───────────────────────────────────────────────────────

        [HttpGet]
        public async Task PaymentMethods(int? id)
        {
            if (id.HasValue)
                await WriteTableJson("SELECT PaymentMethodID,PaymentMethodName FROM webapi.payment_methods WHERE PaymentMethodID = @id", new { id });
            else
                await WriteTableJson("SELECT PaymentMethodID,PaymentMethodName FROM webapi.payment_methods");
        }

        [Authorize, HttpPut]
        public async Task PaymentMethods(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.update_payment_method_from_json(@json, @eid, @uid)", new { json, eid = id, uid = CurrentUserId() });
        }

        [Authorize, HttpPost]
        public async Task PaymentMethods()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.insert_payment_methods_from_json(@json, @uid)", new { json, uid = CurrentUserId() });
        }

        [Authorize, HttpDelete]
        public async Task PaymentMethods(int id) =>
            await ExecFunction("SELECT webapi.delete_payment_method(@id)", new { id });

        // ── DeliveryMethods ──────────────────────────────────────────────────────

        [HttpGet]
        public async Task DeliveryMethods(int? id)
        {
            if (id.HasValue)
                await WriteTableJson("SELECT DeliveryMethodID,DeliveryMethodName FROM webapi.delivery_methods WHERE DeliveryMethodID = @id", new { id });
            else
                await WriteTableJson("SELECT DeliveryMethodID,DeliveryMethodName FROM webapi.delivery_methods");
        }

        [Authorize, HttpPut]
        public async Task DeliveryMethods(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.update_delivery_method_from_json(@json, @eid, @uid)", new { json, eid = id, uid = CurrentUserId() });
        }

        [Authorize, HttpPost]
        public async Task DeliveryMethods()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecFunction("SELECT webapi.insert_delivery_methods_from_json(@json, @uid)", new { json, uid = CurrentUserId() });
        }

        [Authorize, HttpDelete]
        public async Task DeliveryMethods(int id) =>
            await ExecFunction("SELECT webapi.delete_delivery_method(@id)", new { id });
    }
}
