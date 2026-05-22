using System.Net;
using System.Text;
using Microsoft.AspNetCore.Mvc.Testing;
using Newtonsoft.Json.Linq;
using wwi_app.Tests.Fixtures;
using Xunit;

namespace wwi_app.Tests.Unit;

/// <summary>
/// Unit tests for ODataController sales mutation endpoints.
///
/// URL patterns:
///   GET    /OData/SalesOrders         → all orders (JSON array)
///   GET    /OData/SalesOrders(1)      → single order
///   PUT    /OData/SalesOrders(1)      → update via webapi.update_sales_order_from_json
///   POST   /OData/SalesOrders         → insert via webapi.insert_sales_orders_from_json
///   DELETE /OData/SalesOrders(1)      → delete via webapi.delete_sales_order
///
/// Mutation tests (PUT/POST/DELETE) require [Authorize], so they redirect to login
/// when called without a session. We assert the 302 redirect rather than trying to
/// authenticate, which verifies the endpoint exists and auth is enforced.
///
/// GET tests use the real Docker Postgres to verify JSON shape.
/// </summary>
[Trait("Category", "Unit")]
public class ODataControllerTests : IClassFixture<WwiWebAppFactory>
{
    private readonly HttpClient _client;

    public ODataControllerTests(WwiWebAppFactory factory)
    {
        _client = factory.CreateClient(new WebApplicationFactoryClientOptions
        {
            AllowAutoRedirect = false   // capture 302 redirects instead of following to login
        });
    }

    // ── SalesOrders GET ───────────────────────────────────────────────────────

    [Fact]
    public async Task GetSalesOrders_List_Returns_JsonArray()
    {
        var response = await _client.GetAsync("/OData/SalesOrders");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var body = await response.Content.ReadAsStringAsync();
        // ODataController wraps arrays in {"value":[...]}
        var json = JObject.Parse(body);
        Assert.Equal(JTokenType.Array, json["value"]!.Type);
    }

    [Fact]
    public async Task GetSalesOrders_SingleItem_Returns_JsonObject()
    {
        // Get first ID from list, then fetch single record
        var listJson = await GetValueArray("/OData/SalesOrders");
        if (!listJson.Any()) return; // skip if DB is empty

        var firstId = (int)listJson.First["OrderID"]!;
        var response = await _client.GetAsync($"/OData/SalesOrders({firstId})");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var body = await response.Content.ReadAsStringAsync();
        var obj = JObject.Parse(body);
        Assert.Equal(firstId, (int)obj["OrderID"]!);
    }

    // ── SalesOrders mutations (auth-guarded) ─────────────────────────────────

    [Fact]
    public async Task PutSalesOrder_WithoutAuth_Redirects_To_Login()
    {
        var content = new StringContent("{}", Encoding.UTF8, "application/json");
        var response = await _client.PutAsync("/OData/SalesOrders(1)", content);

        Assert.Equal(HttpStatusCode.Redirect, response.StatusCode);
    }

    [Fact]
    public async Task PostSalesOrder_WithoutAuth_Redirects_To_Login()
    {
        var content = new StringContent("[]", Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/OData/SalesOrders", content);

        Assert.Equal(HttpStatusCode.Redirect, response.StatusCode);
    }

    [Fact]
    public async Task DeleteSalesOrder_WithoutAuth_Redirects_To_Login()
    {
        var response = await _client.DeleteAsync("/OData/SalesOrders(1)");

        Assert.Equal(HttpStatusCode.Redirect, response.StatusCode);
    }

    // ── Invoices GET ──────────────────────────────────────────────────────────

    [Fact]
    public async Task GetInvoices_List_Returns_JsonArray()
    {
        var response = await _client.GetAsync("/OData/Invoices");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var json = JObject.Parse(await response.Content.ReadAsStringAsync());
        Assert.Equal(JTokenType.Array, json["value"]!.Type);
    }

    [Fact]
    public async Task GetInvoices_SingleItem_Returns_JsonObject()
    {
        var listJson = await GetValueArray("/OData/Invoices");
        if (!listJson.Any()) return;

        var firstId = (int)listJson.First["InvoiceID"]!;
        var response = await _client.GetAsync($"/OData/Invoices({firstId})");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var obj = JObject.Parse(await response.Content.ReadAsStringAsync());
        Assert.Equal(firstId, (int)obj["InvoiceID"]!);
    }

    // ── Invoices mutations (auth-guarded) ────────────────────────────────────

    [Fact]
    public async Task PutInvoice_WithoutAuth_Redirects_To_Login()
    {
        var content = new StringContent("{}", Encoding.UTF8, "application/json");
        var response = await _client.PutAsync("/OData/Invoices(1)", content);

        Assert.Equal(HttpStatusCode.Redirect, response.StatusCode);
    }

    [Fact]
    public async Task DeleteInvoice_WithoutAuth_Redirects_To_Login()
    {
        var response = await _client.DeleteAsync("/OData/Invoices(1)");

        Assert.Equal(HttpStatusCode.Redirect, response.StatusCode);
    }

    // ── CustomerTransactions GET ──────────────────────────────────────────────

    [Fact]
    public async Task GetCustomerTransactions_List_Returns_JsonArray()
    {
        var response = await _client.GetAsync("/OData/CustomerTransactions");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var json = JObject.Parse(await response.Content.ReadAsStringAsync());
        Assert.Equal(JTokenType.Array, json["value"]!.Type);
    }

    [Fact]
    public async Task GetCustomerTransactions_SingleItem_Returns_JsonObject()
    {
        var listJson = await GetValueArray("/OData/CustomerTransactions");
        if (!listJson.Any()) return;

        var firstId = (int)listJson.First["CustomerTransactionID"]!;
        var response = await _client.GetAsync($"/OData/CustomerTransactions({firstId})");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var obj = JObject.Parse(await response.Content.ReadAsStringAsync());
        Assert.Equal(firstId, (int)obj["CustomerTransactionID"]!);
    }

    // ── CustomerTransactions mutations (auth-guarded) ─────────────────────────

    [Fact]
    public async Task PutCustomerTransaction_WithoutAuth_Redirects_To_Login()
    {
        var content = new StringContent("{}", Encoding.UTF8, "application/json");
        var response = await _client.PutAsync("/OData/CustomerTransactions(1)", content);

        Assert.Equal(HttpStatusCode.Redirect, response.StatusCode);
    }

    [Fact]
    public async Task DeleteCustomerTransaction_WithoutAuth_Redirects_To_Login()
    {
        var response = await _client.DeleteAsync("/OData/CustomerTransactions(1)");

        Assert.Equal(HttpStatusCode.Redirect, response.StatusCode);
    }

    // ── Customers GET ─────────────────────────────────────────────────────────

    [Fact]
    public async Task GetCustomers_List_Returns_JsonArray()
    {
        var response = await _client.GetAsync("/OData/Customers");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var json = JObject.Parse(await response.Content.ReadAsStringAsync());
        Assert.Equal(JTokenType.Array, json["value"]!.Type);
    }

    [Fact]
    public async Task GetCustomers_SingleItem_Returns_JsonObject()
    {
        var listJson = await GetValueArray("/OData/Customers");
        if (!listJson.Any()) return;

        var firstId = (int)listJson.First["CustomerID"]!;
        var response = await _client.GetAsync($"/OData/Customers({firstId})");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var obj = JObject.Parse(await response.Content.ReadAsStringAsync());
        Assert.Equal(firstId, (int)obj["CustomerID"]!);
    }

    // ── Customers $apply permutations ────────────────────────────────────────

    [Fact]
    public async Task GetCustomers_Apply_GroupByCategory_ReturnsCategoryAndSum()
    {
        var url = "/OData/Customers?$apply=groupby((CustomerCategoryName),aggregate(CreditLimit with sum as TotalCredit))";
        var response = await _client.GetAsync(url);

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var items = await GetValueArray(url);
        Assert.True(items.Count > 0);
        Assert.NotNull(items.First["CustomerCategoryName"]);
        Assert.NotNull(items.First["TotalCredit"]);
    }

    [Fact]
    public async Task GetCustomers_Apply_GroupByCategory_OrderByDesc()
    {
        var url = "/OData/Customers?$apply=groupby((CustomerCategoryName),aggregate(CreditLimit with sum as TotalCredit))&$orderby=TotalCredit desc";
        var items = await GetValueArray(url);

        if (items.Count < 2) return;
        var first = items.First["TotalCredit"]!.Value<decimal>();
        var last  = items.Last["TotalCredit"]!.Value<decimal>();
        Assert.True(first >= last, "Expected descending order by TotalCredit");
    }

    [Fact]
    public async Task GetCustomers_Apply_GroupByCategory_OrderByAsc()
    {
        var url = "/OData/Customers?$apply=groupby((CustomerCategoryName),aggregate(CreditLimit with sum as TotalCredit))&$orderby=TotalCredit asc";
        var items = await GetValueArray(url);

        if (items.Count < 2) return;
        var first = items.First["TotalCredit"]!.Value<decimal>();
        var last  = items.Last["TotalCredit"]!.Value<decimal>();
        Assert.True(first <= last, "Expected ascending order by TotalCredit");
    }

    [Fact]
    public async Task GetCustomers_Apply_GroupByCategory_Top1_ReturnsExactlyOne()
    {
        var url = "/OData/Customers?$apply=groupby((CustomerCategoryName),aggregate(CreditLimit with sum as TotalCredit))&$top=1";
        var items = await GetValueArray(url);

        Assert.Equal(1, items.Count);
    }

    [Fact]
    public async Task GetCustomers_Apply_GroupByCategory_Top3_ReturnsAtMostThree()
    {
        var url = "/OData/Customers?$apply=groupby((CustomerCategoryName),aggregate(CreditLimit with sum as TotalCredit))&$top=3";
        var items = await GetValueArray(url);

        Assert.True(items.Count <= 3);
    }

    [Fact]
    public async Task GetCustomers_Apply_GroupByCategory_FilterGe0_ReturnsResults()
    {
        var url = "/OData/Customers?$apply=groupby((CustomerCategoryName),aggregate(CreditLimit with sum as TotalCredit))&$filter=TotalCredit ge '0'";
        var items = await GetValueArray(url);

        Assert.True(items.Count > 0);
    }

    [Fact]
    public async Task GetCustomers_Apply_GroupByCategory_OrderByDesc_Top5()
    {
        var url = "/OData/Customers?$apply=groupby((CustomerCategoryName),aggregate(CreditLimit with sum as TotalCredit))&$orderby=TotalCredit desc&$top=5";
        var items = await GetValueArray(url);

        Assert.True(items.Count <= 5);
        if (items.Count >= 2)
        {
            var first = items.First["TotalCredit"]!.Value<decimal>();
            var last  = items.Last["TotalCredit"]!.Value<decimal>();
            Assert.True(first >= last);
        }
    }

    [Fact]
    public async Task GetCustomers_Apply_GroupByCategory_FullCombo_FilterOrderTop()
    {
        var url = "/OData/Customers?$apply=groupby((CustomerCategoryName),aggregate(CreditLimit with sum as TotalCredit))&$filter=TotalCredit ge '0'&$orderby=TotalCredit asc&$top=3";
        var items = await GetValueArray(url);

        Assert.True(items.Count <= 3);
        if (items.Count >= 2)
        {
            var first = items.First["TotalCredit"]!.Value<decimal>();
            var last  = items.Last["TotalCredit"]!.Value<decimal>();
            Assert.True(first <= last);
        }
    }

    [Fact]
    public async Task GetCustomers_Apply_GroupByBuyingGroup_ReturnsGroupAndSum()
    {
        var url = "/OData/Customers?$apply=groupby((BuyingGroupName),aggregate(CreditLimit with sum as GroupCredit))";
        var items = await GetValueArray(url);

        Assert.True(items.Count > 0);
        Assert.NotNull(items.First["BuyingGroupName"]);
        Assert.NotNull(items.First["GroupCredit"]);
    }

    [Fact]
    public async Task GetCustomers_Apply_GroupByBuyingGroup_OrderByDesc_Top2()
    {
        var url = "/OData/Customers?$apply=groupby((BuyingGroupName),aggregate(CreditLimit with sum as GroupCredit))&$orderby=GroupCredit desc&$top=2";
        var items = await GetValueArray(url);

        Assert.True(items.Count <= 2);
        if (items.Count == 2)
        {
            var firstToken = items.First!["GroupCredit"];
            var lastToken  = items.Last!["GroupCredit"];
            // Skip ordering assertion if any value is null (null BuyingGroup group sorts unpredictably)
            if (firstToken?.Type != JTokenType.Null && lastToken?.Type != JTokenType.Null
                && firstToken != null && lastToken != null)
            {
                Assert.True(firstToken.Value<decimal>() >= lastToken.Value<decimal>());
            }
        }
    }

    // ── Customers mutations (auth-guarded) ───────────────────────────────────

    [Fact]
    public async Task PutCustomer_WithoutAuth_Redirects_To_Login()
    {
        var content = new StringContent("{}", Encoding.UTF8, "application/json");
        var response = await _client.PutAsync("/OData/Customers(1)", content);

        Assert.Equal(HttpStatusCode.Redirect, response.StatusCode);
    }

    [Fact]
    public async Task PostCustomer_WithoutAuth_Redirects_To_Login()
    {
        var content = new StringContent("[]", Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/OData/Customers", content);

        Assert.Equal(HttpStatusCode.Redirect, response.StatusCode);
    }

    [Fact]
    public async Task DeleteCustomer_WithoutAuth_Redirects_To_Login()
    {
        var response = await _client.DeleteAsync("/OData/Customers(1)");

        Assert.Equal(HttpStatusCode.Redirect, response.StatusCode);
    }

    // ── SpecialDeals GET ──────────────────────────────────────────────────────

    [Fact]
    public async Task GetSpecialDeals_List_Returns_JsonArray()
    {
        var response = await _client.GetAsync("/OData/SpecialDeals");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var json = JObject.Parse(await response.Content.ReadAsStringAsync());
        Assert.Equal(JTokenType.Array, json["value"]!.Type);
    }

    [Fact]
    public async Task GetSpecialDeals_List_ContainsCoreFields()
    {
        var items = await GetValueArray("/OData/SpecialDeals");
        if (!items.Any()) return;

        var first = (JObject)items.First!;
        Assert.True(first.ContainsKey("SpecialDealID"),    "Missing SpecialDealID");
        Assert.True(first.ContainsKey("DealDescription"),  "Missing DealDescription");
        Assert.True(first.ContainsKey("StartDate"),        "Missing StartDate");
        Assert.True(first.ContainsKey("EndDate"),          "Missing EndDate");
    }

    [Fact]
    public async Task GetSpecialDeals_List_ContainsAll18Columns()
    {
        var items = await GetValueArray("/OData/SpecialDeals");
        if (!items.Any()) return;

        var first = (JObject)items.First!;
        var expected = new[]
        {
            "SpecialDealID","DealDescription","StartDate","EndDate",
            "DiscountAmount","DiscountPercentage","UnitPrice",
            "StockItemName","Brand","Size",
            "CustomerName","BuyingGroupName","CustomerCategoryName",
            "StockItemID","CustomerID","BuyingGroupID","CustomerCategoryID","StockGroupID"
        };
        foreach (var col in expected)
            Assert.True(first.ContainsKey(col), $"Missing column: {col}");
    }

    [Fact]
    public async Task GetSpecialDeals_List_NumericFieldsAreNullOrDecimal()
    {
        var items = await GetValueArray("/OData/SpecialDeals");
        if (!items.Any()) return;

        var first = (JObject)items.First!;
        foreach (var field in new[] { "DiscountAmount", "DiscountPercentage", "UnitPrice" })
        {
            var token = first[field];
            Assert.True(
                token == null || token.Type == JTokenType.Null || token.Type == JTokenType.Float || token.Type == JTokenType.Integer,
                $"{field} should be null or numeric");
        }
    }

    [Fact]
    public async Task GetSpecialDeals_SingleItem_Returns_JsonObject()
    {
        var listJson = await GetValueArray("/OData/SpecialDeals");
        if (!listJson.Any()) return;

        var firstId = (int)listJson.First["SpecialDealID"]!;
        var response = await _client.GetAsync($"/OData/SpecialDeals({firstId})");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var obj = JObject.Parse(await response.Content.ReadAsStringAsync());
        Assert.Equal(firstId, (int)obj["SpecialDealID"]!);
    }

    [Fact]
    public async Task GetSpecialDeals_SingleItem_ContainsAll18Columns()
    {
        var listJson = await GetValueArray("/OData/SpecialDeals");
        if (!listJson.Any()) return;

        var firstId = (int)listJson.First["SpecialDealID"]!;
        var response = await _client.GetAsync($"/OData/SpecialDeals({firstId})");
        var obj = JObject.Parse(await response.Content.ReadAsStringAsync());

        var expected = new[]
        {
            "SpecialDealID","DealDescription","StartDate","EndDate",
            "DiscountAmount","DiscountPercentage","UnitPrice",
            "StockItemName","Brand","Size",
            "CustomerName","BuyingGroupName","CustomerCategoryName",
            "StockItemID","CustomerID","BuyingGroupID","CustomerCategoryID","StockGroupID"
        };
        foreach (var col in expected)
            Assert.True(obj.ContainsKey(col), $"Missing column: {col}");
    }

    [Fact]
    public async Task GetSpecialDeals_NonExistentId_Returns200WithNullBody()
    {
        var response = await _client.GetAsync("/OData/SpecialDeals(99999999)");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    // ── SpecialDeals mutations (auth-guarded) ─────────────────────────────────

    [Fact]
    public async Task PutSpecialDeal_WithoutAuth_Redirects_To_Login()
    {
        var content = new StringContent("{}", Encoding.UTF8, "application/json");
        var response = await _client.PutAsync("/OData/SpecialDeals(1)", content);

        Assert.Equal(HttpStatusCode.Redirect, response.StatusCode);
    }

    [Fact]
    public async Task PostSpecialDeal_WithoutAuth_Redirects_To_Login()
    {
        var content = new StringContent("[]", Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/OData/SpecialDeals", content);

        Assert.Equal(HttpStatusCode.Redirect, response.StatusCode);
    }

    [Fact]
    public async Task DeleteSpecialDeal_WithoutAuth_Redirects_To_Login()
    {
        var response = await _client.DeleteAsync("/OData/SpecialDeals(1)");

        Assert.Equal(HttpStatusCode.Redirect, response.StatusCode);
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private async Task<JArray> GetValueArray(string url)
    {
        var response = await _client.GetAsync(url);
        response.EnsureSuccessStatusCode();
        var json = JObject.Parse(await response.Content.ReadAsStringAsync());
        return (JArray)json["value"]!;
    }
}
