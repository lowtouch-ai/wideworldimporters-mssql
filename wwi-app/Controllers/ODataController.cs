using Dapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Npgsql;
using System;
using System.IO;
using System.Linq;
using System.Security.Claims;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace wwi_app.Controllers
{
    public partial class ODataController : Controller
    {
        private readonly NpgsqlDataSource _dataSource;

        public ODataController(NpgsqlDataSource dataSource)
        {
            this._dataSource = dataSource;
        }

        // PostgreSQL folds unquoted identifiers to lowercase, so row_to_json produces lowercase keys.
        // This rewrites "(SELECT ColA,ColB FROM" to "(SELECT cola AS "ColA",colb AS "ColB" FROM"
        // so JSON keys match the PascalCase column names the JS DataTables config expects.
        private static string WithPascalCaseJsonKeys(string sql) =>
            Regex.Replace(sql, @"\(SELECT ([\w,]+) FROM ", m =>
            {
                var cols = m.Groups[1].Value.Split(',');
                var aliased = string.Join(",", cols.Select(c => $"{c.ToLower()} AS \"{c}\""));
                return $"(SELECT {aliased} FROM ";
            });

        private async Task StreamJson(string sql, object param = null)
        {
            await using var conn = await _dataSource.OpenConnectionAsync();
            var json = await conn.ExecuteScalarAsync<string>(WithPascalCaseJsonKeys(sql), param);
            Response.ContentType = "application/json";
            // List queries return an array; wrap in {"value":[...]} for DataTables dataSrc:"value"
            var isArray = json != null && json.TrimStart().StartsWith("[");
            await Response.WriteAsync(isArray ? $"{{\"value\":{json}}}" : (json ?? "null"));
        }

        private async Task ExecVoid(string sql, object param = null)
        {
            await using var conn = await _dataSource.OpenConnectionAsync();
            await conn.ExecuteAsync(sql, param);
        }

        private int GetUserId() => Convert.ToInt32(User.FindFirst(ClaimTypes.Sid)?.Value ?? "0");

        // Parses OData $apply=groupby((Col),aggregate(A mul B with sum as Alias))
        // and builds a PostgreSQL GROUP BY query against `fromClause`.
        // Also applies $orderby, $top, $filter when present.
        private async Task StreamApply(string fromClause)
        {
            var apply   = Request.Query["$apply"].ToString();
            var orderby = Request.Query["$orderby"].ToString();
            var top     = Request.Query["$top"].ToString();
            var filter  = Request.Query["$filter"].ToString();

            // Parse: groupby((GroupCol),aggregate(ExprA mul ExprB with sum as Alias))
            //   or:  groupby((GroupCol),aggregate(ExprA with sum as Alias))
            var m = Regex.Match(apply,
                @"groupby\(\((\w+)\),aggregate\((\w+)(?:\s+mul\s+(\w+))?\s+with\s+sum\s+as\s+(\w+)\)\)",
                RegexOptions.IgnoreCase);

            if (!m.Success)
            {
                Response.StatusCode = 400;
                await Response.WriteAsync("Unsupported $apply expression");
                return;
            }

            var groupCol  = m.Groups[1].Value;
            var aggA      = m.Groups[2].Value;
            var aggB      = m.Groups[3].Value; // empty when no mul
            var alias     = m.Groups[4].Value;

            var aggExpr   = string.IsNullOrEmpty(aggB)
                ? $"SUM({aggA.ToLower()})"
                : $"SUM({aggA.ToLower()} * {aggB.ToLower()})";

            var whereClause = "";
            if (!string.IsNullOrEmpty(filter))
            {
                // Support: Col ge 'value'  →  col >= 'value'
                var fm = Regex.Match(filter, @"(\w+)\s+ge\s+'([^']+)'", RegexOptions.IgnoreCase);
                if (fm.Success)
                    whereClause = $"WHERE {fm.Groups[1].Value.ToLower()} >= '{fm.Groups[2].Value}'";
            }

            var orderClause = "";
            if (!string.IsNullOrEmpty(orderby))
            {
                var om = Regex.Match(orderby, @"(\w+)(?:\s+(asc|desc))?", RegexOptions.IgnoreCase);
                if (om.Success)
                {
                    var dir = om.Groups[2].Success ? om.Groups[2].Value.ToUpper() : "ASC";
                    // If ordering by the aggregated column, use the alias (it's not in GROUP BY)
                    var orderCol = om.Groups[1].Value.Equals(aggA, StringComparison.OrdinalIgnoreCase)
                        ? $"\"{alias}\""
                        : om.Groups[1].Value.ToLower();
                    orderClause = $"ORDER BY {orderCol} {dir}";
                }
            }

            var limitClause = string.IsNullOrEmpty(top) ? "" : $"LIMIT {int.Parse(top)}";

            var sql = $@"SELECT COALESCE(json_agg(row_to_json(t))::text,'[]') FROM (
                SELECT {groupCol.ToLower()} AS ""{groupCol}"", {aggExpr} AS ""{alias}""
                FROM {fromClause}
                {whereClause}
                GROUP BY {groupCol.ToLower()}
                {orderClause}
                {limitClause}
            ) t";

            await using var conn = await _dataSource.OpenConnectionAsync();
            var json = await conn.ExecuteScalarAsync<string>(sql);
            Response.ContentType = "application/json";
            await Response.WriteAsync($"{{\"value\":{json ?? "[]"}}}");
        }


        [HttpGet]
        public async Task SalesOrders(int? id)
        {
            if (id == null)
                await StreamJson("SELECT COALESCE(json_agg(row_to_json(t))::text,'[]') FROM (SELECT OrderID,OrderDate,CustomerPurchaseOrderNumber,ExpectedDeliveryDate,PickingCompletedWhen,CustomerID,CustomerName,PhoneNumber,FaxNumber,DeliveryLocation,SalesPerson,SalesPersonPhone,SalesPersonEmail FROM webapi.sales_orders) t");
            else
                await StreamJson("SELECT row_to_json(t)::text FROM (SELECT OrderID,OrderDate,CustomerPurchaseOrderNumber,ExpectedDeliveryDate,PickingCompletedWhen,CustomerID,CustomerName,PhoneNumber,FaxNumber,DeliveryLocation,SalesPerson,SalesPersonPhone,SalesPersonEmail FROM webapi.sales_orders WHERE OrderID=@id) t", new { id });
        }

        [Authorize]
        [HttpPut]
        public async Task SalesOrders(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.update_sales_order_from_json(@json::text, @id, @userId)", new { json, id, userId = GetUserId() });
        }

        [Authorize]
        [HttpPost]
        public async Task SalesOrders()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.insert_sales_orders_from_json(@json::text, @userId)", new { json, userId = GetUserId() });
        }

        [Authorize]
        [HttpDelete]
        public async Task SalesOrders(int id)
        {
            await ExecVoid("SELECT webapi.delete_sales_order(@id)", new { id });
        }


        [HttpGet]
        public async Task SalesOrderLines(int? id)
        {
            if (id == null && Request.Query.ContainsKey("$apply"))
                await StreamApply("webapi.sales_order_lines");
            else if (id == null)
                await StreamJson("SELECT COALESCE(json_agg(row_to_json(t))::text,'[]') FROM (SELECT OrderLineID,OrderID,Description,Quantity,UnitPrice,TaxRate,ProductName,Brand,Size,ColorName,PackageTypeName,PickingCompletedWhen FROM webapi.sales_order_lines) t");
            else
                await StreamJson("SELECT row_to_json(t)::text FROM (SELECT OrderLineID,OrderID,Description,Quantity,UnitPrice,TaxRate,ProductName,Brand,Size,ColorName,PackageTypeName,PickingCompletedWhen FROM webapi.sales_order_lines WHERE OrderLineID=@id) t", new { id });
        }

        [Authorize]
        [HttpPut]
        public async Task SalesOrderLines(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.update_sales_order_line_from_json(@json::text, @id, @userId)", new { json, id, userId = GetUserId() });
        }

        [Authorize]
        [HttpPost]
        public async Task SalesOrderLines()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.insert_sales_order_lines_from_json(@json::text, @userId)", new { json, userId = GetUserId() });
        }

        [Authorize]
        [HttpDelete]
        public async Task SalesOrderLines(int id)
        {
            await ExecVoid("SELECT webapi.delete_sales_order_line(@id)", new { id });
        }


        [HttpGet]
        public async Task PurchaseOrders(int? id)
        {
            if (id == null)
                await StreamJson("SELECT COALESCE(json_agg(row_to_json(t))::text,'[]') FROM (SELECT PurchaseOrderID,OrderDate,ExpectedDeliveryDate,SupplierReference,IsOrderFinalized,DeliveryMethodName,ContactName,ContactPhone,ContactFax,ContactEmail,SupplierID FROM webapi.purchase_orders) t");
            else
                await StreamJson("SELECT row_to_json(t)::text FROM (SELECT PurchaseOrderID,OrderDate,ExpectedDeliveryDate,SupplierReference,IsOrderFinalized,DeliveryMethodName,ContactName,ContactPhone,ContactFax,ContactEmail,SupplierID FROM webapi.purchase_orders WHERE PurchaseOrderID=@id) t", new { id });
        }

        [Authorize]
        [HttpPut]
        public async Task PurchaseOrders(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.update_purchase_order_from_json(@json::text, @id, @userId)", new { json, id, userId = GetUserId() });
        }

        [Authorize]
        [HttpPost]
        public async Task PurchaseOrders()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.insert_purchase_orders_from_json(@json::text, @userId)", new { json, userId = GetUserId() });
        }

        [Authorize]
        [HttpDelete]
        public async Task PurchaseOrders(int id)
        {
            await ExecVoid("SELECT webapi.delete_purchase_order(@id)", new { id });
        }


        [HttpGet]
        public async Task PurchaseOrderLines(int? id)
        {
            if (id == null && Request.Query.ContainsKey("$apply"))
                await StreamApply("webapi.purchase_order_lines");
            else if (id == null)
                await StreamJson("SELECT COALESCE(json_agg(row_to_json(t))::text,'[]') FROM (SELECT PurchaseOrderLineID,PurchaseOrderID,Description,IsOrderLineFinalized,ProductName,Brand,Size,ColorName,PackageTypeName,OrderedOuters,ReceivedOuters,ExpectedUnitPricePerOuter FROM webapi.purchase_order_lines) t");
            else
                await StreamJson("SELECT row_to_json(t)::text FROM (SELECT PurchaseOrderLineID,PurchaseOrderID,Description,IsOrderLineFinalized,ProductName,Brand,Size,ColorName,PackageTypeName,OrderedOuters,ReceivedOuters,ExpectedUnitPricePerOuter FROM webapi.purchase_order_lines WHERE PurchaseOrderLineID=@id) t", new { id });
        }

        [Authorize]
        [HttpPut]
        public async Task PurchaseOrderLines(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.update_purchase_order_line_from_json(@json::text, @id, @userId)", new { json, id, userId = GetUserId() });
        }

        [Authorize]
        [HttpPost]
        public async Task PurchaseOrderLines()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.insert_purchase_order_lines_from_json(@json::text, @userId)", new { json, userId = GetUserId() });
        }

        [Authorize]
        [HttpDelete]
        public async Task PurchaseOrderLines(int id)
        {
            await ExecVoid("SELECT webapi.delete_purchase_order_line(@id)", new { id });
        }


        [HttpGet]
        public async Task Invoices(int? id)
        {
            if (id == null)
                await StreamJson("SELECT COALESCE(json_agg(row_to_json(t))::text,'[]') FROM (SELECT InvoiceID,InvoiceDate,CustomerPurchaseOrderNumber,IsCreditNote,TotalDryItems,TotalChillerItems,DeliveryRun,RunPosition,ReturnedDeliveryData,ConfirmedDeliveryTime,ConfirmedReceivedBy,CustomerName,SalesPersonName,ContactName,ContactPhone,ContactEmail,SalesPersonEmail,DeliveryMethodName,CustomerID,OrderID,DeliveryMethodID,ContactPersonID,AccountsPersonID,SalespersonPersonID,PackedByPersonID FROM webapi.invoices) t");
            else
                await StreamJson("SELECT row_to_json(t)::text FROM (SELECT InvoiceID,InvoiceDate,CustomerPurchaseOrderNumber,IsCreditNote,TotalDryItems,TotalChillerItems,DeliveryRun,RunPosition,ReturnedDeliveryData,ConfirmedDeliveryTime,ConfirmedReceivedBy,CustomerName,SalesPersonName,ContactName,ContactPhone,ContactEmail,SalesPersonEmail,DeliveryMethodName,CustomerID,OrderID,DeliveryMethodID,ContactPersonID,AccountsPersonID,SalespersonPersonID,PackedByPersonID FROM webapi.invoices WHERE InvoiceID=@id) t", new { id });
        }

        [Authorize]
        [HttpPut]
        public async Task Invoices(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.update_invoice_from_json(@json::text, @id, @userId)", new { json, id, userId = GetUserId() });
        }

        [Authorize]
        [HttpPost]
        public async Task Invoices()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.insert_invoices_from_json(@json::text, @userId)", new { json, userId = GetUserId() });
        }

        [Authorize]
        [HttpDelete]
        public async Task Invoices(int id)
        {
            await ExecVoid("SELECT webapi.delete_invoice(@id)", new { id });
        }


        [HttpGet]
        public async Task SpecialDeals(int? id)
        {
            if (id == null)
                await StreamJson("SELECT COALESCE(json_agg(row_to_json(t))::text,'[]') FROM (SELECT SpecialDealID,DealDescription,StartDate,EndDate,DiscountAmount,DiscountPercentage,UnitPrice,StockItemName,Brand,Size,CustomerName,BuyingGroupName,CustomerCategoryName,StockItemID,CustomerID,BuyingGroupID,CustomerCategoryID,StockGroupID FROM webapi.special_deals) t");
            else
                await StreamJson("SELECT row_to_json(t)::text FROM (SELECT SpecialDealID,DealDescription,StartDate,EndDate,DiscountAmount,DiscountPercentage,UnitPrice,StockItemName,Brand,Size,CustomerName,BuyingGroupName,CustomerCategoryName,StockItemID,CustomerID,BuyingGroupID,CustomerCategoryID,StockGroupID FROM webapi.special_deals WHERE SpecialDealID=@id) t", new { id });
        }

        [Authorize]
        [HttpPut]
        public async Task SpecialDeals(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.update_special_deal_from_json(@json::text, @id, @userId)", new { json, id, userId = GetUserId() });
        }

        [Authorize]
        [HttpPost]
        public async Task SpecialDeals()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.insert_special_deals_from_json(@json::text, @userId)", new { json, userId = GetUserId() });
        }

        [Authorize]
        [HttpDelete]
        public async Task SpecialDeals(int id)
        {
            await ExecVoid("SELECT webapi.delete_special_deal(@id)", new { id });
        }


        [HttpGet]
        public async Task CustomerTransactions(int? id)
        {
            if (id == null)
                await StreamJson("SELECT COALESCE(json_agg(row_to_json(t))::text,'[]') FROM (SELECT CustomerTransactionID,TransactionDate,AmountExcludingTax,TaxAmount,TransactionAmount,OutstandingBalance,FinalizationDate,IsFinalized,CustomerName,TransactionTypeName,InvoiceDate,CustomerPurchaseOrderNumber,PaymentMethodName,CustomerID,TransactionTypeID,InvoiceID,PaymentMethodID FROM webapi.customer_transactions) t");
            else
                await StreamJson("SELECT row_to_json(t)::text FROM (SELECT CustomerTransactionID,TransactionDate,AmountExcludingTax,TaxAmount,TransactionAmount,OutstandingBalance,FinalizationDate,IsFinalized,CustomerName,TransactionTypeName,InvoiceDate,CustomerPurchaseOrderNumber,PaymentMethodName,CustomerID,TransactionTypeID,InvoiceID,PaymentMethodID FROM webapi.customer_transactions WHERE CustomerTransactionID=@id) t", new { id });
        }

        [Authorize]
        [HttpPut]
        public async Task CustomerTransactions(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.update_customer_transaction_from_json(@json::text, @id, @userId)", new { json, id, userId = GetUserId() });
        }

        [Authorize]
        [HttpPost]
        public async Task CustomerTransactions()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.insert_customer_transactions_from_json(@json::text, @userId)", new { json, userId = GetUserId() });
        }

        [Authorize]
        [HttpDelete]
        public async Task CustomerTransactions(int id)
        {
            await ExecVoid("SELECT webapi.delete_customer_transaction(@id)", new { id });
        }


        [HttpGet]
        public async Task SupplierTransactions(int? id)
        {
            if (id == null)
                await StreamJson("SELECT COALESCE(json_agg(row_to_json(t))::text,'[]') FROM (SELECT SupplierTransactionID,TransactionDate,AmountExcludingTax,TaxAmount,TransactionAmount,OutstandingBalance,FinalizationDate,IsFinalized,SupplierName,TransactionTypeName,PaymentMethodName,SupplierID,TransactionTypeID,PurchaseOrderID,PaymentMethodID FROM webapi.supplier_transactions) t");
            else
                await StreamJson("SELECT row_to_json(t)::text FROM (SELECT SupplierTransactionID,TransactionDate,AmountExcludingTax,TaxAmount,TransactionAmount,OutstandingBalance,FinalizationDate,IsFinalized,SupplierName,TransactionTypeName,PaymentMethodName,SupplierID,TransactionTypeID,PurchaseOrderID,PaymentMethodID FROM webapi.supplier_transactions WHERE SupplierTransactionID=@id) t", new { id });
        }

        [Authorize]
        [HttpPut]
        public async Task SupplierTransactions(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.update_supplier_transaction_from_json(@json::text, @id, @userId)", new { json, id, userId = GetUserId() });
        }

        [Authorize]
        [HttpPost]
        public async Task SupplierTransactions()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.insert_supplier_transactions_from_json(@json::text, @userId)", new { json, userId = GetUserId() });
        }

        [Authorize]
        [HttpDelete]
        public async Task SupplierTransactions(int id)
        {
            await ExecVoid("SELECT webapi.delete_supplier_transaction(@id)", new { id });
        }


        [HttpGet]
        public async Task Customers(int? id)
        {
            if (id == null && Request.Query.ContainsKey("$apply"))
                await StreamApply("webapi.customers");
            else if (id == null)
                await StreamJson("SELECT COALESCE(json_agg(row_to_json(t))::text,'[]') FROM (SELECT CustomerID,CustomerName,AccountOpenedDate,CustomerCategoryName,PrimaryContact,AlternateContact,PhoneNumber,FaxNumber,WebsiteURL,PostalAddressLine1,PostalAddressLine2,PostalCity,PostalCityID,PostalPostalCode,CreditLimit,IsOnCreditHold,IsStatementSent,PaymentDays,RunPosition,StandardDiscountPercentage,BuyingGroupName,BuyingGroupID,BillToCustomerID,CustomerCategoryID,PrimaryContactPersonID,AlternateContactPersonID FROM webapi.customers) t");
            else
                await StreamJson("SELECT row_to_json(t)::text FROM (SELECT CustomerID,CustomerName,AccountOpenedDate,CustomerCategoryName,PrimaryContact,AlternateContact,PhoneNumber,FaxNumber,WebsiteURL,PostalAddressLine1,PostalAddressLine2,PostalCity,PostalCityID,PostalPostalCode,CreditLimit,IsOnCreditHold,IsStatementSent,PaymentDays,RunPosition,StandardDiscountPercentage,BuyingGroupName,BuyingGroupID,BillToCustomerID,CustomerCategoryID,PrimaryContactPersonID,AlternateContactPersonID FROM webapi.customers WHERE CustomerID=@id) t", new { id });
        }

        [Authorize]
        [HttpPut]
        public async Task Customers(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.update_customer_from_json(@json::text, @id, @userId)", new { json, id, userId = GetUserId() });
        }

        [Authorize]
        [HttpPost]
        public async Task Customers()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.insert_customers_from_json(@json::text, @userId)", new { json, userId = GetUserId() });
        }

        [Authorize]
        [HttpDelete]
        public async Task Customers(int id)
        {
            await ExecVoid("SELECT webapi.delete_customer(@id)", new { id });
        }


        [HttpGet]
        public async Task Suppliers(int? id)
        {
            if (id == null)
                await StreamJson("SELECT COALESCE(json_agg(row_to_json(t))::text,'[]') FROM (SELECT SupplierID,SupplierName,SupplierCategoryName,PrimaryContact,AlternateContact,PhoneNumber,FaxNumber,WebsiteURL,SupplierReference,BankAccountName,BankAccountBranch,BankAccountCode,BankAccountNumber,BankInternationalCode,PostalAddressLine1,PostalAddressLine2,PostalPostalCode,PaymentDays,SupplierCategoryID FROM webapi.suppliers) t");
            else
                await StreamJson("SELECT row_to_json(t)::text FROM (SELECT SupplierID,SupplierName,SupplierCategoryName,PrimaryContact,AlternateContact,PhoneNumber,FaxNumber,WebsiteURL,SupplierReference,BankAccountName,BankAccountBranch,BankAccountCode,BankAccountNumber,BankInternationalCode,PostalAddressLine1,PostalAddressLine2,PostalPostalCode,PaymentDays,SupplierCategoryID FROM webapi.suppliers WHERE SupplierID=@id) t", new { id });
        }

        [Authorize]
        [HttpPut]
        public async Task Suppliers(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.update_supplier_from_json(@json::text, @id, @userId)", new { json, id, userId = GetUserId() });
        }

        [Authorize]
        [HttpPost]
        public async Task Suppliers()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.insert_suppliers_from_json(@json::text, @userId)", new { json, userId = GetUserId() });
        }

        [Authorize]
        [HttpDelete]
        public async Task Suppliers(int id)
        {
            await ExecVoid("SELECT webapi.delete_supplier(@id)", new { id });
        }


        [HttpGet]
        public async Task Countries(int? id)
        {
            if (id == null)
                await StreamJson("SELECT COALESCE(json_agg(row_to_json(t))::text,'[]') FROM (SELECT CountryID,CountryName,FormalName,IsoAlpha3Code,IsoNumericCode,CountryType,LatestRecordedPopulation,Continent,Region,Subregion FROM webapi.countries) t");
            else
                await StreamJson("SELECT row_to_json(t)::text FROM (SELECT CountryID,CountryName,FormalName,IsoAlpha3Code,IsoNumericCode,CountryType,LatestRecordedPopulation,Continent,Region,Subregion FROM webapi.countries WHERE CountryID=@id) t", new { id });
        }

        [Authorize]
        [HttpPut]
        public async Task Countries(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.update_country_from_json(@json::text, @id, @userId)", new { json, id, userId = GetUserId() });
        }

        [Authorize]
        [HttpPost]
        public async Task Countries()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.insert_countries_from_json(@json::text, @userId)", new { json, userId = GetUserId() });
        }

        [Authorize]
        [HttpDelete]
        public async Task Countries(int id)
        {
            await ExecVoid("SELECT webapi.delete_country(@id)", new { id });
        }


        [HttpGet]
        public async Task Cities(int? id)
        {
            if (id == null)
                await StreamJson("SELECT COALESCE(json_agg(row_to_json(t))::text,'[]') FROM (SELECT CityID,CityName,StateProvinceID,StateProvinceName,LatestRecordedPopulation FROM webapi.cities) t");
            else
                await StreamJson("SELECT row_to_json(t)::text FROM (SELECT CityID,CityName,StateProvinceID,StateProvinceName,LatestRecordedPopulation FROM webapi.cities WHERE CityID=@id) t", new { id });
        }

        [Authorize]
        [HttpPut]
        public async Task Cities(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.update_city_from_json(@json::text, @id, @userId)", new { json, id, userId = GetUserId() });
        }

        [Authorize]
        [HttpPost]
        public async Task Cities()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.insert_cities_from_json(@json::text, @userId)", new { json, userId = GetUserId() });
        }

        [Authorize]
        [HttpDelete]
        public async Task Cities(int id)
        {
            await ExecVoid("SELECT webapi.delete_city(@id)", new { id });
        }


        [HttpGet]
        public async Task StateProvinces(int? id)
        {
            if (id == null)
                await StreamJson("SELECT COALESCE(json_agg(row_to_json(t))::text,'[]') FROM (SELECT StateProvinceID,StateProvinceCode,StateProvinceName,CountryID,CountryName,SalesTerritory,LatestRecordedPopulation FROM webapi.state_provinces) t");
            else
                await StreamJson("SELECT row_to_json(t)::text FROM (SELECT StateProvinceID,StateProvinceCode,StateProvinceName,CountryID,CountryName,SalesTerritory,LatestRecordedPopulation FROM webapi.state_provinces WHERE StateProvinceID=@id) t", new { id });
        }

        [Authorize]
        [HttpPut]
        public async Task StateProvinces(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.update_state_province_from_json(@json::text, @id, @userId)", new { json, id, userId = GetUserId() });
        }

        [Authorize]
        [HttpPost]
        public async Task StateProvinces()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.insert_state_provinces_from_json(@json::text, @userId)", new { json, userId = GetUserId() });
        }

        [Authorize]
        [HttpDelete]
        public async Task StateProvinces(int id)
        {
            await ExecVoid("SELECT webapi.delete_state_province(@id)", new { id });
        }


        [HttpGet]
        public async Task StockItems(int? id)
        {
            if (id == null)
                await StreamJson("SELECT COALESCE(json_agg(row_to_json(t))::text,'[]') FROM (SELECT StockItemID,StockItemName,SupplierName,SupplierReference,ColorName,OuterPackage,UnitPackage,Brand,Size,LeadTimeDays,QuantityPerOuter,IsChillerStock,Barcode,TaxRate,UnitPrice,RecommendedRetailPrice,TypicalWeightPerUnit,MarketingComments,InternalComments,CustomFields,QuantityOnHand,BinLocation,LastStocktakeQuantity,LastCostPrice,ReorderLevel,TargetStockLevel,SupplierID,ColorID,UnitPackageID,OuterPackageID FROM webapi.stock_items) t");
            else
                await StreamJson("SELECT row_to_json(t)::text FROM (SELECT StockItemID,StockItemName,SupplierName,SupplierReference,ColorName,OuterPackage,UnitPackage,Brand,Size,LeadTimeDays,QuantityPerOuter,IsChillerStock,Barcode,TaxRate,UnitPrice,RecommendedRetailPrice,TypicalWeightPerUnit,MarketingComments,InternalComments,CustomFields,QuantityOnHand,BinLocation,LastStocktakeQuantity,LastCostPrice,ReorderLevel,TargetStockLevel,SupplierID,ColorID,UnitPackageID,OuterPackageID FROM webapi.stock_items WHERE StockItemID=@id) t", new { id });
        }

        [Authorize]
        [HttpPut]
        public async Task StockItems(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.update_stock_item_from_json(@json::text, @id, @userId)", new { json, id, userId = GetUserId() });
        }

        [Authorize]
        [HttpPost]
        public async Task StockItems()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.insert_stock_items_from_json(@json::text, @userId)", new { json, userId = GetUserId() });
        }

        [Authorize]
        [HttpDelete]
        public async Task StockItems(int id)
        {
            await ExecVoid("SELECT webapi.delete_stock_item(@id)", new { id });
        }


        [HttpGet]
        public async Task PackageTypes(int? id)
        {
            if (id == null)
                await StreamJson("SELECT COALESCE(json_agg(row_to_json(t))::text,'[]') FROM (SELECT PackageTypeID,PackageTypeName FROM webapi.package_types) t");
            else
                await StreamJson("SELECT row_to_json(t)::text FROM (SELECT PackageTypeID,PackageTypeName FROM webapi.package_types WHERE PackageTypeID=@id) t", new { id });
        }

        [Authorize]
        [HttpPut]
        public async Task PackageTypes(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.update_package_type_from_json(@json::text, @id, @userId)", new { json, id, userId = GetUserId() });
        }

        [Authorize]
        [HttpPost]
        public async Task PackageTypes()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.insert_package_types_from_json(@json::text, @userId)", new { json, userId = GetUserId() });
        }

        [Authorize]
        [HttpDelete]
        public async Task PackageTypes(int id)
        {
            await ExecVoid("SELECT webapi.delete_package_type(@id)", new { id });
        }


        [HttpGet]
        public async Task Colors(int? id)
        {
            if (id == null)
                await StreamJson("SELECT COALESCE(json_agg(row_to_json(t))::text,'[]') FROM (SELECT ColorID,ColorName FROM webapi.colors) t");
            else
                await StreamJson("SELECT row_to_json(t)::text FROM (SELECT ColorID,ColorName FROM webapi.colors WHERE ColorID=@id) t", new { id });
        }

        [Authorize]
        [HttpPut]
        public async Task Colors(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.update_color_from_json(@json::text, @id, @userId)", new { json, id, userId = GetUserId() });
        }

        [Authorize]
        [HttpPost]
        public async Task Colors()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.insert_colors_from_json(@json::text, @userId)", new { json, userId = GetUserId() });
        }

        [Authorize]
        [HttpDelete]
        public async Task Colors(int id)
        {
            await ExecVoid("SELECT webapi.delete_color(@id)", new { id });
        }


        [HttpGet]
        public async Task StockGroups(int? id)
        {
            if (id == null)
                await StreamJson("SELECT COALESCE(json_agg(row_to_json(t))::text,'[]') FROM (SELECT StockGroupID,StockGroupName FROM webapi.stock_groups) t");
            else
                await StreamJson("SELECT row_to_json(t)::text FROM (SELECT StockGroupID,StockGroupName FROM webapi.stock_groups WHERE StockGroupID=@id) t", new { id });
        }

        [Authorize]
        [HttpPut]
        public async Task StockGroups(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.update_stock_group_from_json(@json::text, @id, @userId)", new { json, id, userId = GetUserId() });
        }

        [Authorize]
        [HttpPost]
        public async Task StockGroups()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.insert_stock_groups_from_json(@json::text, @userId)", new { json, userId = GetUserId() });
        }

        [Authorize]
        [HttpDelete]
        public async Task StockGroups(int id)
        {
            await ExecVoid("SELECT webapi.delete_stock_group(@id)", new { id });
        }


        [HttpGet]
        public async Task BuyingGroups(int? id)
        {
            if (id == null)
                await StreamJson("SELECT COALESCE(json_agg(row_to_json(t))::text,'[]') FROM (SELECT BuyingGroupID,BuyingGroupName FROM webapi.buying_groups) t");
            else
                await StreamJson("SELECT row_to_json(t)::text FROM (SELECT BuyingGroupID,BuyingGroupName FROM webapi.buying_groups WHERE BuyingGroupID=@id) t", new { id });
        }

        [Authorize]
        [HttpPut]
        public async Task BuyingGroups(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.update_buying_group_from_json(@json::text, @id, @userId)", new { json, id, userId = GetUserId() });
        }

        [Authorize]
        [HttpPost]
        public async Task BuyingGroups()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.insert_buying_groups_from_json(@json::text, @userId)", new { json, userId = GetUserId() });
        }

        [Authorize]
        [HttpDelete]
        public async Task BuyingGroups(int id)
        {
            await ExecVoid("SELECT webapi.delete_buying_group(@id)", new { id });
        }


        [HttpGet]
        public async Task CustomerCategories(int? id)
        {
            if (id == null)
                await StreamJson("SELECT COALESCE(json_agg(row_to_json(t))::text,'[]') FROM (SELECT CustomerCategoryID,CustomerCategoryName FROM webapi.customer_categories) t");
            else
                await StreamJson("SELECT row_to_json(t)::text FROM (SELECT CustomerCategoryID,CustomerCategoryName FROM webapi.customer_categories WHERE CustomerCategoryID=@id) t", new { id });
        }

        [Authorize]
        [HttpPut]
        public async Task CustomerCategories(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.update_customer_category_from_json(@json::text, @id, @userId)", new { json, id, userId = GetUserId() });
        }

        [Authorize]
        [HttpPost]
        public async Task CustomerCategories()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.insert_customer_categories_from_json(@json::text, @userId)", new { json, userId = GetUserId() });
        }

        [Authorize]
        [HttpDelete]
        public async Task CustomerCategories(int id)
        {
            await ExecVoid("SELECT webapi.delete_customer_category(@id)", new { id });
        }


        [HttpGet]
        public async Task SupplierCategories(int? id)
        {
            if (id == null)
                await StreamJson("SELECT COALESCE(json_agg(row_to_json(t))::text,'[]') FROM (SELECT SupplierCategoryID,SupplierCategoryName FROM webapi.supplier_categories) t");
            else
                await StreamJson("SELECT row_to_json(t)::text FROM (SELECT SupplierCategoryID,SupplierCategoryName FROM webapi.supplier_categories WHERE SupplierCategoryID=@id) t", new { id });
        }

        [Authorize]
        [HttpPut]
        public async Task SupplierCategories(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.update_supplier_category_from_json(@json::text, @id, @userId)", new { json, id, userId = GetUserId() });
        }

        [Authorize]
        [HttpPost]
        public async Task SupplierCategories()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.insert_supplier_categories_from_json(@json::text, @userId)", new { json, userId = GetUserId() });
        }

        [Authorize]
        [HttpDelete]
        public async Task SupplierCategories(int id)
        {
            await ExecVoid("SELECT webapi.delete_supplier_category(@id)", new { id });
        }


        [HttpGet]
        public async Task TransactionTypes(int? id)
        {
            if (id == null)
                await StreamJson("SELECT COALESCE(json_agg(row_to_json(t))::text,'[]') FROM (SELECT TransactionTypeID,TransactionTypeName FROM webapi.transaction_types) t");
            else
                await StreamJson("SELECT row_to_json(t)::text FROM (SELECT TransactionTypeID,TransactionTypeName FROM webapi.transaction_types WHERE TransactionTypeID=@id) t", new { id });
        }

        [Authorize]
        [HttpPut]
        public async Task TransactionTypes(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.update_transaction_type_from_json(@json::text, @id, @userId)", new { json, id, userId = GetUserId() });
        }

        [Authorize]
        [HttpPost]
        public async Task TransactionTypes()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.insert_transaction_types_from_json(@json::text, @userId)", new { json, userId = GetUserId() });
        }

        [Authorize]
        [HttpDelete]
        public async Task TransactionTypes(int id)
        {
            await ExecVoid("SELECT webapi.delete_transaction_type(@id)", new { id });
        }


        [HttpGet]
        public async Task PaymentMethods(int? id)
        {
            if (id == null)
                await StreamJson("SELECT COALESCE(json_agg(row_to_json(t))::text,'[]') FROM (SELECT PaymentMethodID,PaymentMethodName FROM webapi.payment_methods) t");
            else
                await StreamJson("SELECT row_to_json(t)::text FROM (SELECT PaymentMethodID,PaymentMethodName FROM webapi.payment_methods WHERE PaymentMethodID=@id) t", new { id });
        }

        [Authorize]
        [HttpPut]
        public async Task PaymentMethods(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.update_payment_method_from_json(@json::text, @id, @userId)", new { json, id, userId = GetUserId() });
        }

        [Authorize]
        [HttpPost]
        public async Task PaymentMethods()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.insert_payment_methods_from_json(@json::text, @userId)", new { json, userId = GetUserId() });
        }

        [Authorize]
        [HttpDelete]
        public async Task PaymentMethods(int id)
        {
            await ExecVoid("SELECT webapi.delete_payment_method(@id)", new { id });
        }


        [HttpGet]
        public async Task DeliveryMethods(int? id)
        {
            if (id == null)
                await StreamJson("SELECT COALESCE(json_agg(row_to_json(t))::text,'[]') FROM (SELECT DeliveryMethodID,DeliveryMethodName FROM webapi.delivery_methods) t");
            else
                await StreamJson("SELECT row_to_json(t)::text FROM (SELECT DeliveryMethodID,DeliveryMethodName FROM webapi.delivery_methods WHERE DeliveryMethodID=@id) t", new { id });
        }

        [Authorize]
        [HttpPut]
        public async Task DeliveryMethods(int id, string body)
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.update_delivery_method_from_json(@json::text, @id, @userId)", new { json, id, userId = GetUserId() });
        }

        [Authorize]
        [HttpPost]
        public async Task DeliveryMethods()
        {
            var json = await new StreamReader(Request.Body).ReadToEndAsync();
            await ExecVoid("SELECT webapi.insert_delivery_methods_from_json(@json::text, @userId)", new { json, userId = GetUserId() });
        }

        [Authorize]
        [HttpDelete]
        public async Task DeliveryMethods(int id)
        {
            await ExecVoid("SELECT webapi.delete_delivery_method(@id)", new { id });
        }
    }
}
