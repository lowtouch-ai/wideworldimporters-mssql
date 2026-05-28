using Dapper;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Npgsql;
using System.Net;
using System.Threading.Tasks;

namespace WideWorldImportersFunctions
{
    public class OData
    {
        private readonly NpgsqlDataSource _db;
        private readonly ILogger<OData> _log;

        public OData(NpgsqlDataSource db, ILogger<OData> log)
        {
            _db = db;
            _log = log;
        }

        private async Task<HttpResponseData> QueryView(HttpRequestData req, string sql)
        {
            await using var conn = await _db.OpenConnectionAsync();
            var rows = await conn.QueryAsync(sql);
            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "application/json; charset=utf-8");
            await response.WriteStringAsync(JsonConvert.SerializeObject(new { value = rows }));
            return response;
        }

        [Function("SalesOrders")]
        public async Task<HttpResponseData> SalesOrders(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req)
        {
            _log.LogInformation("SalesOrders triggered.");
            return await QueryView(req,
                "SELECT OrderID,OrderDate,CustomerPurchaseOrderNumber,ExpectedDeliveryDate,PickingCompletedWhen,CustomerID,CustomerName,PhoneNumber,FaxNumber,WebsiteURL,DeliveryLocation,SalesPerson,SalesPersonPhone,SalesPersonEmail FROM webapi.sales_orders");
        }

        [Function("SalesOrderLines")]
        public async Task<HttpResponseData> SalesOrderLines(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req)
        {
            _log.LogInformation("SalesOrderLines triggered.");
            return await QueryView(req,
                "SELECT OrderLineID,OrderID,Description,Quantity,UnitPrice,TaxRate,ProductName,Brand,Size,ColorName,PackageTypeName,PickingCompletedWhen FROM webapi.sales_order_lines");
        }

        [Function("PurchaseOrders")]
        public async Task<HttpResponseData> PurchaseOrders(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req)
        {
            _log.LogInformation("PurchaseOrders triggered.");
            return await QueryView(req,
                "SELECT PurchaseOrderID,OrderDate,ExpectedDeliveryDate,SupplierReference,IsOrderFinalized,DeliveryMethodName,ContactName,ContactPhone,ContactFax,ContactEmail,SupplierID FROM webapi.purchase_orders");
        }

        [Function("PurchaseOrderLines")]
        public async Task<HttpResponseData> PurchaseOrderLines(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req)
        {
            _log.LogInformation("PurchaseOrderLines triggered.");
            return await QueryView(req,
                "SELECT PurchaseOrderLineID,PurchaseOrderID,Description,IsOrderLineFinalized,ProductName,Brand,Size,ColorName,PackageTypeName,OrderedOuters,ReceivedOuters,ExpectedUnitPricePerOuter FROM webapi.purchase_order_lines");
        }

        [Function("Invoices")]
        public async Task<HttpResponseData> Invoices(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req)
        {
            _log.LogInformation("Invoices triggered.");
            return await QueryView(req,
                "SELECT InvoiceID,InvoiceDate,CustomerPurchaseOrderNumber,IsCreditNote,TotalDryItems,TotalChillerItems,DeliveryRun,RunPosition,ReturnedDeliveryData,ConfirmedDeliveryTime,ConfirmedReceivedBy,CustomerName,SalesPersonName,ContactName,ContactPhone,ContactEmail,SalesPersonEmail,DeliveryMethodName,CustomerID,OrderID,DeliveryMethodID,ContactPersonID,AccountsPersonID,SalespersonPersonID,PackedByPersonID FROM webapi.invoices");
        }

        [Function("SpecialDeals")]
        public async Task<HttpResponseData> SpecialDeals(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req)
        {
            _log.LogInformation("SpecialDeals triggered.");
            return await QueryView(req,
                "SELECT SpecialDealID,DealDescription,StartDate,EndDate,DiscountAmount,DiscountPercentage,UnitPrice,StockItemName,Brand,Size,CustomerName,BuyingGroupName,CustomerCategoryName,StockItemID,CustomerID,BuyingGroupID,CustomerCategoryID,StockGroupID FROM webapi.special_deals");
        }

        [Function("CustomerTransactions")]
        public async Task<HttpResponseData> CustomerTransactions(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req)
        {
            _log.LogInformation("CustomerTransactions triggered.");
            return await QueryView(req,
                "SELECT CustomerTransactionID,TransactionDate,AmountExcludingTax,TaxAmount,TransactionAmount,OutstandingBalance,FinalizationDate,IsFinalized,CustomerName,TransactionTypeName,InvoiceDate,CustomerPurchaseOrderNumber,PaymentMethodName,CustomerID,TransactionTypeID,InvoiceID,PaymentMethodID FROM webapi.customer_transactions");
        }

        [Function("SupplierTransactions")]
        public async Task<HttpResponseData> SupplierTransactions(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req)
        {
            _log.LogInformation("SupplierTransactions triggered.");
            return await QueryView(req,
                "SELECT SupplierTransactionID,TransactionDate,AmountExcludingTax,TaxAmount,TransactionAmount,OutstandingBalance,FinalizationDate,IsFinalized,SupplierName,TransactionTypeName,PaymentMethodName,SupplierID,TransactionTypeID,PurchaseOrderID,PaymentMethodID,OrderDate,IsOrderFinalized,ExpectedDeliveryDate,SupplierReference FROM webapi.supplier_transactions");
        }

        [Function("Customers")]
        public async Task<HttpResponseData> Customers(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req)
        {
            _log.LogInformation("Customers triggered.");
            return await QueryView(req,
                "SELECT CustomerID,CustomerName,AccountOpenedDate,CustomerCategoryName,PrimaryContact,AlternateContact,PhoneNumber,FaxNumber,WebsiteURL,PostalAddressLine1,PostalAddressLine2,PostalCity,PostalCityID,PostalPostalCode,CreditLimit,IsOnCreditHold,IsStatementSent,PaymentDays,RunPosition,StandardDiscountPercentage,BuyingGroupName,DeliveryLocation,BuyingGroupID,BillToCustomerID,CustomerCategoryID,PrimaryContactPersonID,AlternateContactPersonID FROM webapi.customers");
        }

        [Function("Suppliers")]
        public async Task<HttpResponseData> Suppliers(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req)
        {
            _log.LogInformation("Suppliers triggered.");
            return await QueryView(req,
                "SELECT SupplierID,SupplierName,SupplierCategoryName,PrimaryContact,AlternateContact,PhoneNumber,FaxNumber,WebsiteURL,SupplierReference,DeliveryLocation,BankAccountName,BankAccountBranch,BankAccountCode,BankAccountNumber,BankInternationalCode,PostalAddressLine1,PostalAddressLine2,PostalPostalCode,PaymentDays,SupplierCategoryID FROM webapi.suppliers");
        }

        [Function("Countries")]
        public async Task<HttpResponseData> Countries(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req)
        {
            _log.LogInformation("Countries triggered.");
            return await QueryView(req,
                "SELECT CountryID,CountryName,FormalName,IsoAlpha3Code,IsoNumericCode,CountryType,LatestRecordedPopulation,Continent,Region,Subregion FROM webapi.countries");
        }

        [Function("Cities")]
        public async Task<HttpResponseData> Cities(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req)
        {
            _log.LogInformation("Cities triggered.");
            return await QueryView(req,
                "SELECT CityID,CityName,StateProvinceID,LatestRecordedPopulation FROM webapi.cities");
        }

        [Function("StateProvinces")]
        public async Task<HttpResponseData> StateProvinces(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req)
        {
            _log.LogInformation("StateProvinces triggered.");
            return await QueryView(req,
                "SELECT StateProvinceID,StateProvinceCode,StateProvinceName,CountryID,SalesTerritory,LatestRecordedPopulation FROM webapi.state_provinces");
        }

        [Function("StockItems")]
        public async Task<HttpResponseData> StockItems(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req)
        {
            _log.LogInformation("StockItems triggered.");
            return await QueryView(req,
                "SELECT StockItemID,StockItemName,SupplierName,SupplierReference,ColorName,OuterPackage,UnitPackage,Brand,Size,LeadTimeDays,QuantityPerOuter,IsChillerStock,Barcode,TaxRate,UnitPrice,RecommendedRetailPrice,TypicalWeightPerUnit,MarketingComments,InternalComments,CustomFields,QuantityOnHand,BinLocation,LastStocktakeQuantity,LastCostPrice,ReorderLevel,TargetStockLevel,SupplierID,ColorID,UnitPackageID,OuterPackageID FROM webapi.stock_items");
        }

        [Function("PackageTypes")]
        public async Task<HttpResponseData> PackageTypes(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req)
        {
            _log.LogInformation("PackageTypes triggered.");
            return await QueryView(req,
                "SELECT PackageTypeID,PackageTypeName FROM webapi.package_types");
        }

        [Function("Colors")]
        public async Task<HttpResponseData> Colors(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req)
        {
            _log.LogInformation("Colors triggered.");
            return await QueryView(req,
                "SELECT ColorID,ColorName FROM webapi.colors");
        }

        [Function("StockGroups")]
        public async Task<HttpResponseData> StockGroups(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req)
        {
            _log.LogInformation("StockGroups triggered.");
            return await QueryView(req,
                "SELECT StockGroupID,StockGroupName FROM webapi.stock_groups");
        }

        [Function("BuyingGroups")]
        public async Task<HttpResponseData> BuyingGroups(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req)
        {
            _log.LogInformation("BuyingGroups triggered.");
            return await QueryView(req,
                "SELECT BuyingGroupID,BuyingGroupName FROM webapi.buying_groups");
        }

        [Function("CustomerCategories")]
        public async Task<HttpResponseData> CustomerCategories(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req)
        {
            _log.LogInformation("CustomerCategories triggered.");
            return await QueryView(req,
                "SELECT CustomerCategoryID,CustomerCategoryName FROM webapi.customer_categories");
        }

        [Function("SupplierCategories")]
        public async Task<HttpResponseData> SupplierCategories(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req)
        {
            _log.LogInformation("SupplierCategories triggered.");
            return await QueryView(req,
                "SELECT SupplierCategoryID,SupplierCategoryName FROM webapi.supplier_categories");
        }

        [Function("TransactionTypes")]
        public async Task<HttpResponseData> TransactionTypes(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req)
        {
            _log.LogInformation("TransactionTypes triggered.");
            return await QueryView(req,
                "SELECT TransactionTypeID,TransactionTypeName FROM webapi.transaction_types");
        }

        [Function("PaymentMethods")]
        public async Task<HttpResponseData> PaymentMethods(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req)
        {
            _log.LogInformation("PaymentMethods triggered.");
            return await QueryView(req,
                "SELECT PaymentMethodID,PaymentMethodName FROM webapi.payment_methods");
        }

        [Function("DeliveryMethods")]
        public async Task<HttpResponseData> DeliveryMethods(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req)
        {
            _log.LogInformation("DeliveryMethods triggered.");
            return await QueryView(req,
                "SELECT DeliveryMethodID,DeliveryMethodName FROM webapi.delivery_methods");
        }
    }
}
