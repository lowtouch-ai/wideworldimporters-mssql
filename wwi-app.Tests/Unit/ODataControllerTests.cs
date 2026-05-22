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

    // ── Helpers ───────────────────────────────────────────────────────────────

    private async Task<JArray> GetValueArray(string url)
    {
        var response = await _client.GetAsync(url);
        response.EnsureSuccessStatusCode();
        var json = JObject.Parse(await response.Content.ReadAsStringAsync());
        return (JArray)json["value"]!;
    }
}
