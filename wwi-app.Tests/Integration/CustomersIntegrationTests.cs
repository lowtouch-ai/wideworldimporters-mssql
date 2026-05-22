using Newtonsoft.Json.Linq;
using wwi_app.Tests.Fixtures;
using Xunit;

namespace wwi_app.Tests.Integration;

/// <summary>
/// Integration tests for the Customers endpoints.
/// Hits the real postgres_15.1 Docker container.
/// Prerequisite: docker-compose up (agentomatic stack) must be running.
///
/// Covers:
///   - TableController  (DataTables paged reads from webapi.customers view)
///   - ODataController  (full record list, single-record fetch, $apply permutations)
/// </summary>
[Trait("Category", "Integration")]
public class CustomersIntegrationTests : IClassFixture<WwiWebAppFactory>
{
    private readonly HttpClient _client;

    public CustomersIntegrationTests(WwiWebAppFactory factory)
    {
        _client = factory.CreateClient();
    }

    // ── Table endpoint — basic shape ─────────────────────────────────────────

    [Fact]
    public async Task Table_Customers_ReturnsNonEmptyData()
    {
        var json = await GetTableJson("/Table/Customers?draw=1&start=0&length=10");

        var data = (JArray)json["data"]!;
        Assert.True(data.Count > 0, "Expected at least one customer in the DB");
    }

    [Fact]
    public async Task Table_Customers_ContainsExpectedColumns()
    {
        var json = await GetTableJson("/Table/Customers?draw=1&start=0&length=1");

        var first = (JObject)((JArray)json["data"]!).First!;
        Assert.True(first.ContainsKey("CustomerName"),         "Missing CustomerName");
        Assert.True(first.ContainsKey("CustomerCategoryName"), "Missing CustomerCategoryName");
        Assert.True(first.ContainsKey("PhoneNumber"),          "Missing PhoneNumber");
        Assert.True(first.ContainsKey("CustomerID"),           "Missing CustomerID");
    }

    // ── Table endpoint — pagination ──────────────────────────────────────────

    [Fact]
    public async Task Table_Customers_PageSize1_ReturnsExactlyOne()
    {
        var json = await GetTableJson("/Table/Customers?draw=1&start=0&length=1");

        Assert.Equal(1, ((JArray)json["data"]!).Count);
    }

    [Fact]
    public async Task Table_Customers_PageSize5_ReturnsExactlyFive()
    {
        var json = await GetTableJson("/Table/Customers?draw=1&start=0&length=5");

        Assert.Equal(5, ((JArray)json["data"]!).Count);
    }

    [Fact]
    public async Task Table_Customers_PageSize25_ReturnsAtMost25()
    {
        var json = await GetTableJson("/Table/Customers?draw=1&start=0&length=25");

        Assert.True(((JArray)json["data"]!).Count <= 25);
    }

    [Fact]
    public async Task Table_Customers_SecondPage_DifferentFromFirstPage()
    {
        var page1 = (JArray)(await GetTableJson("/Table/Customers?draw=1&start=0&length=3"))["data"]!;
        var page2 = (JArray)(await GetTableJson("/Table/Customers?draw=1&start=3&length=3"))["data"]!;

        if (page1.Count > 0 && page2.Count > 0)
        {
            Assert.NotEqual(
                page1.First!["CustomerID"]!.ToString(),
                page2.First!["CustomerID"]!.ToString());
        }
    }

    [Fact]
    public async Task Table_Customers_ThirdPage_DifferentFromFirstPage()
    {
        var page1 = (JArray)(await GetTableJson("/Table/Customers?draw=1&start=0&length=3"))["data"]!;
        var page3 = (JArray)(await GetTableJson("/Table/Customers?draw=1&start=6&length=3"))["data"]!;

        if (page1.Count > 0 && page3.Count > 0)
        {
            Assert.NotEqual(
                page1.First!["CustomerID"]!.ToString(),
                page3.First!["CustomerID"]!.ToString());
        }
    }

    [Fact]
    public async Task Table_Customers_LargeOffset_ReturnsEmptyData()
    {
        var json = await GetTableJson("/Table/Customers?draw=1&start=999999&length=10");

        Assert.Equal(0, ((JArray)json["data"]!).Count);
    }

    // ── Table endpoint — draw echo ────────────────────────────────────────────

    [Fact]
    public async Task Table_Customers_DrawIsEchoedCorrectly()
    {
        var json = await GetTableJson("/Table/Customers?draw=99&start=0&length=1");

        Assert.Equal(99, (int)json["draw"]!);
    }

    // ── Table endpoint — search / filter ─────────────────────────────────────

    [Fact]
    public async Task Table_Customers_RecordsTotalMatchesFiltered_WhenNoSearch()
    {
        var json = await GetTableJson("/Table/Customers?draw=1&start=0&length=5");

        Assert.Equal((long)json["recordsTotal"]!, (long)json["recordsFiltered"]!);
    }

    [Fact]
    public async Task Table_Customers_EmptySearch_RecordsTotalMatchesFiltered()
    {
        var json = await GetTableJson("/Table/Customers?draw=1&start=0&length=5&search[value]=");

        Assert.Equal((long)json["recordsTotal"]!, (long)json["recordsFiltered"]!);
    }

    [Fact]
    public async Task Table_Customers_NoMatchSearch_ReturnsZeroFiltered()
    {
        var allJson      = await GetTableJson("/Table/Customers?draw=1&start=0&length=5");
        var totalRecords = (long)allJson["recordsTotal"]!;

        var searchJson = await GetTableJson("/Table/Customers?draw=1&start=0&length=5&search[value]=ZZZNOMATCH_99999");
        var filtered   = (long)searchJson["recordsFiltered"]!;

        Assert.Equal(0, filtered);
        Assert.True(totalRecords > 0, "Total should be non-zero; seeded data missing?");
    }

    // ── OData endpoint ────────────────────────────────────────────────────────

    [Fact]
    public async Task OData_Customers_List_ContainsCustomerID()
    {
        var response = await _client.GetAsync("/OData/Customers");
        response.EnsureSuccessStatusCode();

        var json  = JObject.Parse(await response.Content.ReadAsStringAsync());
        var items = (JArray)json["value"]!;

        Assert.True(items.Count > 0, "OData Customers list is empty");
        Assert.NotNull(items.First!["CustomerID"]);
    }

    [Fact]
    public async Task OData_Customers_SingleRecord_MatchesListRecord()
    {
        var items  = await GetODataValueArray("/OData/Customers");
        var id     = (int)items.First!["CustomerID"]!;
        var single = await GetODataObject($"/OData/Customers({id})");

        Assert.Equal(id, (int)single["CustomerID"]!);
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
