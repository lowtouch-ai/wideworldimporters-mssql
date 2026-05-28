using Newtonsoft.Json.Linq;
using wwi_app.Tests.Fixtures;
using Xunit;

namespace wwi_app.Tests.Integration;

/// <summary>
/// Integration tests for the StockGroups endpoints.
/// Hits the real postgres_15.1 Docker container.
/// Prerequisite: docker-compose up (agentomatic stack) must be running.
///
/// Covers:
///   - ODataController  (full record list, single-record fetch)
/// </summary>
[Trait("Category", "Integration")]
public class StockGroupsIntegrationTests : IClassFixture<WwiWebAppFactory>
{
    private readonly HttpClient _client;

    public StockGroupsIntegrationTests(WwiWebAppFactory factory)
    {
        _client = factory.CreateClient();
    }

    // ── OData endpoint ────────────────────────────────────────────────────────

    [Fact]
    public async Task OData_StockGroups_List_ReturnsNonEmptyData()
    {
        var response = await _client.GetAsync("/OData/StockGroups");
        response.EnsureSuccessStatusCode();

        var json  = JObject.Parse(await response.Content.ReadAsStringAsync());
        var items = (JArray)json["value"]!;

        Assert.True(items.Count > 0, "OData StockGroups list is empty");
    }

    [Fact]
    public async Task OData_StockGroups_List_ContainsExpectedFields()
    {
        var items = await GetODataValueArray("/OData/StockGroups");
        var first = (JObject)items.First!;

        Assert.True(first.ContainsKey("StockGroupID"),   "Missing StockGroupID");
        Assert.True(first.ContainsKey("StockGroupName"), "Missing StockGroupName");
    }

    [Fact]
    public async Task OData_StockGroups_SingleRecord_MatchesListRecord()
    {
        var items  = await GetODataValueArray("/OData/StockGroups");
        var id     = (int)items.First!["StockGroupID"]!;
        var single = await GetODataObject($"/OData/StockGroups({id})");

        Assert.Equal(id, (int)single["StockGroupID"]!);
    }

    [Fact]
    public async Task OData_StockGroups_SingleRecord_ContainsStockGroupName()
    {
        var items  = await GetODataValueArray("/OData/StockGroups");
        var id     = (int)items.First!["StockGroupID"]!;
        var single = await GetODataObject($"/OData/StockGroups({id})");

        Assert.NotNull(single["StockGroupName"]);
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

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
