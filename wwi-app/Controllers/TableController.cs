using Dapper;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using Npgsql;
using System.Threading.Tasks;

namespace wwi_app.Controllers
{
    public class TableController : Controller
    {
        private readonly NpgsqlDataSource _db;

        public TableController(NpgsqlDataSource db)
        {
            _db = db;
        }

        private async Task WriteJson(string sql)
        {
            await using var conn = await _db.OpenConnectionAsync();
            var rows = await conn.QueryAsync(sql);
            Response.ContentType = "application/json";
            await Response.WriteAsync(JsonConvert.SerializeObject(new { value = rows }));
        }

        public async Task SalesOrders() => await WriteJson(
            "SELECT OrderDate, CustomerPurchaseOrderNumber, CustomerName, ExpectedDeliveryDate, PhoneNumber, SalesPerson, OrderID FROM webapi.sales_orders");

        public async Task PurchaseOrders() => await WriteJson(
            "SELECT OrderDate, SupplierReference, ExpectedDeliveryDate, ContactName, ContactPhone, IsOrderFinalized, PurchaseOrderID FROM webapi.purchase_orders");

        public async Task Invoices() => await WriteJson(
            "SELECT InvoiceDate, CustomerPurchaseOrderNumber, CustomerName, SalesPersonName, ContactName, ContactPhone, SalesPersonEmail, InvoiceID FROM webapi.invoices");

        public async Task CustomerTransactions() => await WriteJson(
            "SELECT TransactionDate, TransactionAmount, IsFinalized, CustomerName, TransactionTypeName, PaymentMethodName, InvoiceDate, CustomerTransactionID FROM webapi.customer_transactions");

        public async Task SupplierTransactions() => await WriteJson(
            "SELECT TransactionDate, TransactionAmount, IsFinalized, SupplierName, TransactionTypeName, PaymentMethodName, SupplierTransactionID FROM webapi.supplier_transactions");

        public async Task Customers() => await WriteJson(
            "SELECT CustomerName, CustomerCategoryName, PhoneNumber, FaxNumber, BuyingGroupName, CustomerID FROM webapi.customers");

        public async Task Suppliers() => await WriteJson(
            "SELECT SupplierName, SupplierCategoryName, PhoneNumber, FaxNumber, PrimaryContact, SupplierID FROM webapi.suppliers");

        public async Task Countries() => await WriteJson(
            "SELECT FormalName, Subregion, Region, Continent, LatestRecordedPopulation, CountryID FROM webapi.countries");

        public async Task Cities() => await WriteJson(
            "SELECT CityName, LatestRecordedPopulation, StateProvinceName, CityID FROM webapi.cities");

        public async Task StateProvinces() => await WriteJson(
            "SELECT StateProvinceName, StateProvinceCode, SalesTerritory, LatestRecordedPopulation, CountryName, StateProvinceID FROM webapi.state_provinces");

        public async Task StockItems() => await WriteJson(
            "SELECT StockItemName, SupplierName, UnitPrice, TaxRate, RecommendedRetailPrice, StockItemID FROM webapi.stock_items");
    }
}
