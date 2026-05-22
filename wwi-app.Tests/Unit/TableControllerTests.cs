using System.Net;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.DependencyInjection;
using Newtonsoft.Json.Linq;
using Npgsql;
using wwi_app.Tests.Fixtures;
using Xunit;

namespace wwi_app.Tests.Unit;

/// <summary>
/// Unit tests for TableController read endpoints (SalesOrders, Invoices, CustomerTransactions).
/// These tests use a real Docker Postgres connection but focus on HTTP response shape and
/// DataTables JSON contract — not on data accuracy (that's covered by Integration tests).
///
/// URL pattern: GET /Table/{Action}?draw=1&start=0&length=10&search[value]=
/// Response contract: { "draw": N, "recordsTotal": N, "recordsFiltered": N, "data": [...] }
/// </summary>
[Trait("Category", "Unit")]
public class TableControllerTests : IClassFixture<WwiWebAppFactory>
{
    private readonly HttpClient _client;

    public TableControllerTests(WwiWebAppFactory factory)
    {
        _client = factory.CreateClient(new WebApplicationFactoryClientOptions
        {
            AllowAutoRedirect = false
        });
    }

    // ── SalesOrders ──────────────────────────────────────────────────────────

    [Fact]
    public async Task SalesOrders_Returns_DataTable_Json_Shape()
    {
        var response = await _client.GetAsync("/Table/SalesOrders?draw=1&start=0&length=5");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Equal("application/json", response.Content.Headers.ContentType?.MediaType);

        var body = await response.Content.ReadAsStringAsync();
        var json = JObject.Parse(body);

        Assert.NotNull(json["draw"]);
        Assert.NotNull(json["recordsTotal"]);
        Assert.NotNull(json["recordsFiltered"]);
        Assert.NotNull(json["data"]);
        Assert.Equal(JTokenType.Array, json["data"]!.Type);
    }

    [Fact]
    public async Task SalesOrders_Pagination_Respects_Length_Parameter()
    {
        var response = await _client.GetAsync("/Table/SalesOrders?draw=1&start=0&length=3");
        response.EnsureSuccessStatusCode();

        var json = JObject.Parse(await response.Content.ReadAsStringAsync());
        var data = (JArray)json["data"]!;

        Assert.True(data.Count <= 3, $"Expected at most 3 rows but got {data.Count}");
    }

    [Fact]
    public async Task SalesOrders_Offset_Changes_Results()
    {
        var page1 = await GetDataRows("/Table/SalesOrders?draw=1&start=0&length=2");
        var page2 = await GetDataRows("/Table/SalesOrders?draw=1&start=2&length=2");

        // Page 1 and page 2 should not contain the same first rows
        if (page1.Count > 0 && page2.Count > 0)
            Assert.NotEqual(page1[0].ToString(), page2[0].ToString());
    }

    [Fact]
    public async Task SalesOrders_Search_Returns_Subset()
    {
        var allResponse  = await _client.GetAsync("/Table/SalesOrders?draw=1&start=0&length=100");
        var allJson      = JObject.Parse(await allResponse.Content.ReadAsStringAsync());
        var totalRecords = (long)allJson["recordsTotal"]!;

        // Search for a term unlikely to match everything
        var searchResponse = await _client.GetAsync("/Table/SalesOrders?draw=1&start=0&length=100&search[value]=xyz_no_match_expected_zzz");
        var searchJson     = JObject.Parse(await searchResponse.Content.ReadAsStringAsync());
        var filtered       = (long)searchJson["recordsFiltered"]!;

        Assert.True(filtered <= totalRecords);
    }

    // ── Invoices ─────────────────────────────────────────────────────────────

    [Fact]
    public async Task Invoices_Returns_DataTable_Json_Shape()
    {
        var response = await _client.GetAsync("/Table/Invoices?draw=1&start=0&length=5");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        var json = JObject.Parse(await response.Content.ReadAsStringAsync());
        Assert.NotNull(json["draw"]);
        Assert.NotNull(json["data"]);
        Assert.Equal(JTokenType.Array, json["data"]!.Type);
    }

    [Fact]
    public async Task Invoices_Pagination_Respects_Length_Parameter()
    {
        var response = await _client.GetAsync("/Table/Invoices?draw=1&start=0&length=4");
        response.EnsureSuccessStatusCode();

        var json = JObject.Parse(await response.Content.ReadAsStringAsync());
        var data = (JArray)json["data"]!;

        Assert.True(data.Count <= 4, $"Expected at most 4 rows but got {data.Count}");
    }

    // ── CustomerTransactions ─────────────────────────────────────────────────

    [Fact]
    public async Task CustomerTransactions_Returns_DataTable_Json_Shape()
    {
        var response = await _client.GetAsync("/Table/CustomerTransactions?draw=1&start=0&length=5");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        var json = JObject.Parse(await response.Content.ReadAsStringAsync());
        Assert.NotNull(json["draw"]);
        Assert.NotNull(json["data"]);
        Assert.Equal(JTokenType.Array, json["data"]!.Type);
    }

    [Fact]
    public async Task CustomerTransactions_Pagination_Respects_Length_Parameter()
    {
        var response = await _client.GetAsync("/Table/CustomerTransactions?draw=1&start=0&length=4");
        response.EnsureSuccessStatusCode();

        var json = JObject.Parse(await response.Content.ReadAsStringAsync());
        var data = (JArray)json["data"]!;

        Assert.True(data.Count <= 4, $"Expected at most 4 rows but got {data.Count}");
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private async Task<JArray> GetDataRows(string url)
    {
        var response = await _client.GetAsync(url);
        response.EnsureSuccessStatusCode();
        var json = JObject.Parse(await response.Content.ReadAsStringAsync());
        return (JArray)json["data"]!;
    }
}
