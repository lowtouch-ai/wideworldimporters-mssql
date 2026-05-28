using Newtonsoft.Json.Linq;
using wwi_app.Tests.Fixtures;
using Xunit;

namespace wwi_app.Tests.Integration;

/// <summary>
/// Integration tests for the PurchaseOrders endpoints.
/// Hits the real postgres_15.1 Docker container.
/// Prerequisite: docker-compose up (agentomatic stack) must be running.
///
/// Covers:
///   - TableController  (DataTables paged reads from webapi.purchase_orders view)
///   - ODataController  (full record list and single-record fetch)
/// </summary>
[Trait("Category", "Integration")]
public class PurchaseOrdersIntegrationTests : IClassFixture<WwiWebAppFactory>
{
    private readonly HttpClient _client;

    public PurchaseOrdersIntegrationTests(WwiWebAppFactory factory)
    {
        _client = factory.CreateClient();
    }

    // ── Table endpoint (DataTables) ───────────────────────────────────────────

    [Fact]
    public async Task Table_PurchaseOrders_ReturnsNonEmptyData()
    {
        var json = await GetTableJson("/Table/PurchaseOrders?draw=1&start=0&length=10");

        var data = (JArray)json["data"]!;
        Assert.True(data.Count > 0, "Expected at least one purchase order in the DB");
    }

    [Fact]
    public async Task Table_PurchaseOrders_ContainsExpectedColumns()
    {
        var json  = await GetTableJson("/Table/PurchaseOrders?draw=1&start=0&length=1");
        var first = (JObject)((JArray)json["data"]!).First!;

        Assert.True(first.ContainsKey("OrderDate"),            "Missing OrderDate");
        Assert.True(first.ContainsKey("SupplierReference"),    "Missing SupplierReference");
        Assert.True(first.ContainsKey("ExpectedDeliveryDate"), "Missing ExpectedDeliveryDate");
        Assert.True(first.ContainsKey("ContactName"),          "Missing ContactName");
        Assert.True(first.ContainsKey("ContactPhone"),         "Missing ContactPhone");
        Assert.True(first.ContainsKey("IsOrderFinalized"),     "Missing IsOrderFinalized");
        Assert.True(first.ContainsKey("PurchaseOrderID"),      "Missing PurchaseOrderID");
    }

    [Fact]
    public async Task Table_PurchaseOrders_RecordsTotalMatchesFiltered_WhenNoSearch()
    {
        var json = await GetTableJson("/Table/PurchaseOrders?draw=1&start=0&length=5");

        var total    = (long)json["recordsTotal"]!;
        var filtered = (long)json["recordsFiltered"]!;
        Assert.Equal(total, filtered);
    }

    [Fact]
    public async Task Table_PurchaseOrders_Pagination_ReturnsCorrectPageSize()
    {
        var json = await GetTableJson("/Table/PurchaseOrders?draw=1&start=0&length=3");

        var data = (JArray)json["data"]!;
        Assert.Equal(3, data.Count);
    }

    [Fact]
    public async Task Table_PurchaseOrders_SecondPage_DifferentFromFirstPage()
    {
        var page1 = (JArray)(await GetTableJson("/Table/PurchaseOrders?draw=1&start=0&length=3"))["data"]!;
        var page2 = (JArray)(await GetTableJson("/Table/PurchaseOrders?draw=1&start=3&length=3"))["data"]!;

        if (page1.Count > 0 && page2.Count > 0)
        {
            var id1 = page1.First!["PurchaseOrderID"]!.ToString();
            var id2 = page2.First!["PurchaseOrderID"]!.ToString();
            Assert.NotEqual(id1, id2);
        }
    }

    [Fact]
    public async Task Table_PurchaseOrders_Search_FiltersResults()
    {
        var allJson      = await GetTableJson("/Table/PurchaseOrders?draw=1&start=0&length=5");
        var totalRecords = (long)allJson["recordsTotal"]!;

        var searchJson = await GetTableJson("/Table/PurchaseOrders?draw=1&start=0&length=5&search[value]=ZZZNOMATCH_99999");
        var filtered   = (long)searchJson["recordsFiltered"]!;

        Assert.Equal(0, filtered);
        Assert.True(totalRecords > 0, "Total should be non-zero; seeded data missing?");
    }

    // ── OData endpoint ────────────────────────────────────────────────────────

    [Fact]
    public async Task OData_PurchaseOrders_List_ReturnsNonEmptyArray()
    {
        var items = await GetODataValueArray("/OData/PurchaseOrders");
        Assert.True(items.Count > 0, "Expected at least one purchase order in the DB");
    }

    [Fact]
    public async Task OData_PurchaseOrders_List_ContainsCoreFields()
    {
        var items = await GetODataValueArray("/OData/PurchaseOrders");
        if (!items.Any()) return;

        var first = (JObject)items.First!;
        Assert.True(first.ContainsKey("PurchaseOrderID"),   "Missing PurchaseOrderID");
        Assert.True(first.ContainsKey("OrderDate"),         "Missing OrderDate");
        Assert.True(first.ContainsKey("IsOrderFinalized"),  "Missing IsOrderFinalized");
        Assert.True(first.ContainsKey("SupplierID"),        "Missing SupplierID");
    }

    [Fact]
    public async Task OData_PurchaseOrders_List_ContainsAll11Columns()
    {
        var items = await GetODataValueArray("/OData/PurchaseOrders");
        if (!items.Any()) return;

        var first    = (JObject)items.First!;
        var expected = new[]
        {
            "PurchaseOrderID", "OrderDate", "ExpectedDeliveryDate", "SupplierReference",
            "IsOrderFinalized", "DeliveryMethodName", "ContactName", "ContactPhone",
            "ContactFax", "ContactEmail", "SupplierID"
        };
        foreach (var col in expected)
            Assert.True(first.ContainsKey(col), $"Missing column: {col}");
    }

    [Fact]
    public async Task OData_PurchaseOrders_SingleRecord_MatchesListRecord()
    {
        var items  = await GetODataValueArray("/OData/PurchaseOrders");
        var id     = (int)items.First!["PurchaseOrderID"]!;
        var single = await GetODataObject($"/OData/PurchaseOrders({id})");

        Assert.Equal(id, (int)single["PurchaseOrderID"]!);
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
