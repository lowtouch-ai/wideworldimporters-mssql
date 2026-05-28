using Newtonsoft.Json.Linq;
using wwi_app.Tests.Fixtures;
using Xunit;

namespace wwi_app.Tests.Integration;

/// <summary>
/// Integration tests for the SalesOrders endpoints.
/// Hits the real postgres_15.1 Docker container.
/// Prerequisite: docker-compose up (agentomatic stack) must be running.
///
/// Covers:
///   - TableController (DataTables paged reads from webapi.sales_orders view)
///   - ODataController (full record list and single-record fetch)
/// </summary>
[Trait("Category", "Integration")]
public class SalesOrdersIntegrationTests : IClassFixture<WwiWebAppFactory>
{
    private readonly HttpClient _client;

    public SalesOrdersIntegrationTests(WwiWebAppFactory factory)
    {
        _client = factory.CreateClient();
    }

    // ── Table endpoint (DataTables) ───────────────────────────────────────────

    [Fact]
    public async Task Table_SalesOrders_ReturnsNonEmptyData()
    {
        var json = await GetTableJson("/Table/SalesOrders?draw=1&start=0&length=10");

        var data = (JArray)json["data"]!;
        Assert.True(data.Count > 0, "Expected at least one sales order in the DB");
    }

    [Fact]
    public async Task Table_SalesOrders_ContainsExpectedColumns()
    {
        var json = await GetTableJson("/Table/SalesOrders?draw=1&start=0&length=1");

        var first = (JObject)((JArray)json["data"]!).First!;
        // Columns defined in TableController.StreamTable call
        Assert.True(first.ContainsKey("OrderDate"), "Missing OrderDate");
        Assert.True(first.ContainsKey("CustomerPurchaseOrderNumber"), "Missing CustomerPurchaseOrderNumber");
        Assert.True(first.ContainsKey("OrderID"), "Missing OrderID");
    }

    [Fact]
    public async Task Table_SalesOrders_RecordsTotalMatchesFiltered_WhenNoSearch()
    {
        var json = await GetTableJson("/Table/SalesOrders?draw=1&start=0&length=5");

        var total    = (long)json["recordsTotal"]!;
        var filtered = (long)json["recordsFiltered"]!;
        Assert.Equal(total, filtered);
    }

    [Fact]
    public async Task Table_SalesOrders_Pagination_ReturnsCorrectPageSize()
    {
        var json = await GetTableJson("/Table/SalesOrders?draw=1&start=0&length=3");

        var data = (JArray)json["data"]!;
        Assert.Equal(3, data.Count);
    }

    [Fact]
    public async Task Table_SalesOrders_SecondPage_DifferentFromFirstPage()
    {
        var page1 = (JArray)(await GetTableJson("/Table/SalesOrders?draw=1&start=0&length=3"))["data"]!;
        var page2 = (JArray)(await GetTableJson("/Table/SalesOrders?draw=1&start=3&length=3"))["data"]!;

        if (page1.Count > 0 && page2.Count > 0)
        {
            var id1 = page1.First!["OrderID"]!.ToString();
            var id2 = page2.First!["OrderID"]!.ToString();
            Assert.NotEqual(id1, id2);
        }
    }

    [Fact]
    public async Task Table_SalesOrders_Search_FiltersResults()
    {
        var allJson      = await GetTableJson("/Table/SalesOrders?draw=1&start=0&length=5");
        var totalRecords = (long)allJson["recordsTotal"]!;

        // Use a search term that matches nothing — filtered count should be 0
        var searchJson = await GetTableJson("/Table/SalesOrders?draw=1&start=0&length=5&search[value]=ZZZNOMATCH_99999");
        var filtered   = (long)searchJson["recordsFiltered"]!;

        Assert.Equal(0, filtered);
        Assert.True(totalRecords > 0, "Total should be non-zero; seeded data missing?");
    }

    // ── OData endpoint ────────────────────────────────────────────────────────

    [Fact]
    public async Task OData_SalesOrders_List_ContainsOrderID()
    {
        var response = await _client.GetAsync("/OData/SalesOrders");
        response.EnsureSuccessStatusCode();

        var json  = JObject.Parse(await response.Content.ReadAsStringAsync());
        var items = (JArray)json["value"]!;

        Assert.True(items.Count > 0, "OData SalesOrders list is empty");
        Assert.True(items.First!["OrderID"] != null, "OrderID field missing from OData response");
    }

    [Fact]
    public async Task OData_SalesOrders_SingleRecord_MatchesListRecord()
    {
        var items  = await GetODataValueArray("/OData/SalesOrders");
        var id     = (int)items.First!["OrderID"]!;
        var single = await GetODataObject($"/OData/SalesOrders({id})");

        Assert.Equal(id, (int)single["OrderID"]!);
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private async Task<JObject> GetTableJson(string url)
    {
        var response = await _client.GetAsync(url);
        response.EnsureSuccessStatusCode();
        return JObject.Parse(await response.Content.ReadAsStringAsync());
    }

    private async Task<JArray> GetODataValueArray(string url)
    {
        var response = await _client.GetAsync(url);
        response.EnsureSuccessStatusCode();
        return (JArray)JObject.Parse(await response.Content.ReadAsStringAsync())["value"]!;
    }

    private async Task<JObject> GetODataObject(string url)
    {
        var response = await _client.GetAsync(url);
        response.EnsureSuccessStatusCode();
        return JObject.Parse(await response.Content.ReadAsStringAsync());
    }
}
