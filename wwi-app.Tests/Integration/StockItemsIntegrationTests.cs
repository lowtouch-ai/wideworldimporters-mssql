using Newtonsoft.Json.Linq;
using wwi_app.Tests.Fixtures;
using Xunit;

namespace wwi_app.Tests.Integration;

/// <summary>
/// Integration tests for the StockItems endpoints.
/// Hits the real postgres_15.1 Docker container.
/// Prerequisite: docker-compose up (agentomatic stack) must be running.
///
/// Covers:
///   - TableController  (DataTables paged reads from webapi.stock_items view)
///   - ODataController  (full record list, single-record fetch)
/// </summary>
[Trait("Category", "Integration")]
public class StockItemsIntegrationTests : IClassFixture<WwiWebAppFactory>
{
    private readonly HttpClient _client;

    public StockItemsIntegrationTests(WwiWebAppFactory factory)
    {
        _client = factory.CreateClient();
    }

    // ── Table endpoint — basic shape ─────────────────────────────────────────

    [Fact]
    public async Task Table_StockItems_ReturnsNonEmptyData()
    {
        var json = await GetTableJson("/Table/StockItems?draw=1&start=0&length=10");

        var data = (JArray)json["data"]!;
        Assert.True(data.Count > 0, "Expected at least one stock item in the DB");
    }

    [Fact]
    public async Task Table_StockItems_ContainsExpectedColumns()
    {
        var json = await GetTableJson("/Table/StockItems?draw=1&start=0&length=1");

        var first = (JObject)((JArray)json["data"]!).First!;
        Assert.True(first.ContainsKey("StockItemID"),             "Missing StockItemID");
        Assert.True(first.ContainsKey("StockItemName"),           "Missing StockItemName");
        Assert.True(first.ContainsKey("SupplierName"),            "Missing SupplierName");
        Assert.True(first.ContainsKey("UnitPrice"),               "Missing UnitPrice");
        Assert.True(first.ContainsKey("TaxRate"),                 "Missing TaxRate");
        Assert.True(first.ContainsKey("RecommendedRetailPrice"),  "Missing RecommendedRetailPrice");
    }

    // ── Table endpoint — pagination ──────────────────────────────────────────

    [Fact]
    public async Task Table_StockItems_PageSize1_ReturnsExactlyOne()
    {
        var json = await GetTableJson("/Table/StockItems?draw=1&start=0&length=1");

        Assert.Equal(1, ((JArray)json["data"]!).Count);
    }

    [Fact]
    public async Task Table_StockItems_PageSize5_ReturnsExactlyFive()
    {
        var json = await GetTableJson("/Table/StockItems?draw=1&start=0&length=5");

        Assert.Equal(5, ((JArray)json["data"]!).Count);
    }

    [Fact]
    public async Task Table_StockItems_PageSize25_ReturnsAtMost25()
    {
        var json = await GetTableJson("/Table/StockItems?draw=1&start=0&length=25");

        Assert.True(((JArray)json["data"]!).Count <= 25);
    }

    [Fact]
    public async Task Table_StockItems_SecondPage_DifferentFromFirstPage()
    {
        var page1 = (JArray)(await GetTableJson("/Table/StockItems?draw=1&start=0&length=3"))["data"]!;
        var page2 = (JArray)(await GetTableJson("/Table/StockItems?draw=1&start=3&length=3"))["data"]!;

        if (page1.Count > 0 && page2.Count > 0)
        {
            Assert.NotEqual(
                page1.First!["StockItemID"]!.ToString(),
                page2.First!["StockItemID"]!.ToString());
        }
    }

    [Fact]
    public async Task Table_StockItems_ThirdPage_DifferentFromFirstPage()
    {
        var page1 = (JArray)(await GetTableJson("/Table/StockItems?draw=1&start=0&length=3"))["data"]!;
        var page3 = (JArray)(await GetTableJson("/Table/StockItems?draw=1&start=6&length=3"))["data"]!;

        if (page1.Count > 0 && page3.Count > 0)
        {
            Assert.NotEqual(
                page1.First!["StockItemID"]!.ToString(),
                page3.First!["StockItemID"]!.ToString());
        }
    }

    [Fact]
    public async Task Table_StockItems_LargeOffset_ReturnsEmptyData()
    {
        var json = await GetTableJson("/Table/StockItems?draw=1&start=999999&length=10");

        Assert.Equal(0, ((JArray)json["data"]!).Count);
    }

    // ── Table endpoint — draw echo ────────────────────────────────────────────

    [Fact]
    public async Task Table_StockItems_DrawIsEchoedCorrectly()
    {
        var json = await GetTableJson("/Table/StockItems?draw=99&start=0&length=1");

        Assert.Equal(99, (int)json["draw"]!);
    }

    // ── Table endpoint — search / filter ─────────────────────────────────────

    [Fact]
    public async Task Table_StockItems_RecordsTotalMatchesFiltered_WhenNoSearch()
    {
        var json = await GetTableJson("/Table/StockItems?draw=1&start=0&length=5");

        Assert.Equal((long)json["recordsTotal"]!, (long)json["recordsFiltered"]!);
    }

    [Fact]
    public async Task Table_StockItems_EmptySearch_RecordsTotalMatchesFiltered()
    {
        var json = await GetTableJson("/Table/StockItems?draw=1&start=0&length=5&search[value]=");

        Assert.Equal((long)json["recordsTotal"]!, (long)json["recordsFiltered"]!);
    }

    [Fact]
    public async Task Table_StockItems_NoMatchSearch_ReturnsZeroFiltered()
    {
        var allJson      = await GetTableJson("/Table/StockItems?draw=1&start=0&length=5");
        var totalRecords = (long)allJson["recordsTotal"]!;

        var searchJson = await GetTableJson("/Table/StockItems?draw=1&start=0&length=5&search[value]=ZZZNOMATCH_99999");
        var filtered   = (long)searchJson["recordsFiltered"]!;

        Assert.Equal(0, filtered);
        Assert.True(totalRecords > 0, "Total should be non-zero; seeded data missing?");
    }

    // ── OData endpoint ────────────────────────────────────────────────────────

    [Fact]
    public async Task OData_StockItems_List_ContainsStockItemID()
    {
        var response = await _client.GetAsync("/OData/StockItems");
        response.EnsureSuccessStatusCode();

        var json  = JObject.Parse(await response.Content.ReadAsStringAsync());
        var items = (JArray)json["value"]!;

        Assert.True(items.Count > 0, "OData StockItems list is empty");
        Assert.NotNull(items.First!["StockItemID"]);
    }

    [Fact]
    public async Task OData_StockItems_SingleRecord_MatchesListRecord()
    {
        var items  = await GetODataValueArray("/OData/StockItems");
        var id     = (int)items.First!["StockItemID"]!;
        var single = await GetODataObject($"/OData/StockItems({id})");

        Assert.Equal(id, (int)single["StockItemID"]!);
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
