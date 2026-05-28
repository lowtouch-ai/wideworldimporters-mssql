using System.Linq;
using System.Threading.Tasks;
using Dapper;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Npgsql;

namespace wwi_app.Controllers
{
    public class TableController : Controller
    {
        private readonly NpgsqlDataSource _dataSource;

        public TableController(NpgsqlDataSource dataSource)
        {
            this._dataSource = dataSource;
        }

        private async Task StreamTable(string viewName, string cols)
        {
            var colNames = cols.Split(',').Select(c => c.Trim()).ToArray();
            var colListSql = string.Join(",", colNames.Select(c => $"{c.ToLowerInvariant()} AS \"{c}\""));

            var draw   = Request.Query["draw"].FirstOrDefault();
            var start  = int.TryParse(Request.Query["start"].FirstOrDefault(),  out var s) ? s : 0;
            var length = int.TryParse(Request.Query["length"].FirstOrDefault(), out var l) ? l : 10;
            var search = Request.Query["search[value]"].FirstOrDefault() ?? "";

            await using var conn = await _dataSource.OpenConnectionAsync();

            var totalCount    = await conn.ExecuteScalarAsync<long>($"SELECT COUNT(*) FROM {viewName}");
            long filteredCount;
            string dataJson;

            if (string.IsNullOrWhiteSpace(search))
            {
                filteredCount = totalCount;
                dataJson = await conn.ExecuteScalarAsync<string>(
                    $"SELECT COALESCE(json_agg(row_to_json(t))::text,'[]') FROM (SELECT {colListSql} FROM {viewName} LIMIT @length OFFSET @start) t",
                    new { length, start });
            }
            else
            {
                var whereParts = colNames.Select(c => $"{c.ToLowerInvariant()}::text ILIKE @search");
                var where = $"WHERE {string.Join(" OR ", whereParts)}";
                var p = new { search = $"%{search}%", length, start };
                filteredCount = await conn.ExecuteScalarAsync<long>($"SELECT COUNT(*) FROM {viewName} {where}", p);
                dataJson = await conn.ExecuteScalarAsync<string>(
                    $"SELECT COALESCE(json_agg(row_to_json(t))::text,'[]') FROM (SELECT {colListSql} FROM {viewName} {where} LIMIT @length OFFSET @start) t", p);
            }

            Response.ContentType = "application/json";
            await Response.WriteAsync(
                $"{{\"draw\":{draw ?? "0"},\"recordsTotal\":{totalCount},\"recordsFiltered\":{filteredCount},\"data\":{dataJson ?? "[]"}}}");
        }

        public async Task SalesOrders()
        {
            await StreamTable("webapi.sales_orders", "OrderDate,CustomerPurchaseOrderNumber,CustomerName,ExpectedDeliveryDate,PhoneNumber,SalesPerson,OrderID");
        }

        public async Task PurchaseOrders()
        {
            await StreamTable("webapi.purchase_orders", "OrderDate,SupplierReference,ExpectedDeliveryDate,ContactName,ContactPhone,IsOrderFinalized,PurchaseOrderID");
        }

        public async Task Invoices()
        {
            await StreamTable("webapi.invoices", "InvoiceDate,CustomerPurchaseOrderNumber,CustomerName,SalesPersonName,ContactName,ContactPhone,SalesPersonEmail,InvoiceID");
        }

        public async Task CustomerTransactions()
        {
            await StreamTable("webapi.customer_transactions", "TransactionDate,TransactionAmount,IsFinalized,CustomerName,TransactionTypeName,PaymentMethodName,InvoiceDate,CustomerTransactionID");
        }

        public async Task SupplierTransactions()
        {
            await StreamTable("webapi.supplier_transactions", "TransactionDate,TransactionAmount,IsFinalized,SupplierName,TransactionTypeName,PaymentMethodName,SupplierTransactionID");
        }

        public async Task Customers()
        {
            await StreamTable("webapi.customers", "CustomerName,CustomerCategoryName,PhoneNumber,FaxNumber,BuyingGroupName,CustomerID");
        }

        public async Task Suppliers()
        {
            await StreamTable("webapi.suppliers", "SupplierName,SupplierCategoryName,PhoneNumber,FaxNumber,PrimaryContact,SupplierID");
        }

        public async Task Countries()
        {
            await StreamTable("webapi.countries", "FormalName,Subregion,Region,Continent,LatestRecordedPopulation,CountryID");
        }

        public async Task Cities()
        {
            await StreamTable("webapi.cities", "CityName,LatestRecordedPopulation,CityID");
        }

        public async Task StateProvinces()
        {
            await StreamTable("webapi.state_provinces", "StateProvinceName,StateProvinceCode,SalesTerritory,LatestRecordedPopulation,StateProvinceID");
        }

        public async Task StockItems()
        {
            await StreamTable("webapi.stock_items", "StockItemName,SupplierName,UnitPrice,TaxRate,RecommendedRetailPrice,StockItemID");
        }
    }
}
