using Newtonsoft.Json.Linq;
using wwi_app.Tests.Fixtures;
using Xunit;

namespace wwi_app.Tests.Integration;

/// <summary>
/// Integration tests for the Colors endpoints.
/// Hits the real postgres_15.1 Docker container.
/// Prerequisite: docker-compose up (agentomatic stack) must be running.
///
/// Covers:
///   - ODataController  (full record list, single-record fetch)
/// </summary>
[Trait("Category", "Integration")]
public class ColorsIntegrationTests : IClassFixture<WwiWebAppFactory>
{
    private readonly HttpClient _client;

    public ColorsIntegrationTests(WwiWebAppFactory factory)
    {
        _client = factory.CreateClient();
    }

    // ── OData endpoint ────────────────────────────────────────────────────────

    [Fact]
    public async Task OData_Colors_List_ReturnsNonEmptyData()
    {
        var response = await _client.GetAsync("/OData/Colors");
        response.EnsureSuccessStatusCode();

        var json  = JObject.Parse(await response.Content.ReadAsStringAsync());
        var items = (JArray)json["value"]!;

        Assert.True(items.Count > 0, "OData Colors list is empty");
    }

    [Fact]
    public async Task OData_Colors_List_ContainsExpectedFields()
    {
        var items = await GetODataValueArray("/OData/Colors");
        var first = (JObject)items.First!;

        Assert.True(first.ContainsKey("ColorID"),   "Missing ColorID");
        Assert.True(first.ContainsKey("ColorName"), "Missing ColorName");
    }

    [Fact]
    public async Task OData_Colors_SingleRecord_MatchesListRecord()
    {
        var items  = await GetODataValueArray("/OData/Colors");
        var id     = (int)items.First!["ColorID"]!;
        var single = await GetODataObject($"/OData/Colors({id})");

        Assert.Equal(id, (int)single["ColorID"]!);
    }

    [Fact]
    public async Task OData_Colors_SingleRecord_ContainsColorName()
    {
        var items  = await GetODataValueArray("/OData/Colors");
        var id     = (int)items.First!["ColorID"]!;
        var single = await GetODataObject($"/OData/Colors({id})");

        Assert.NotNull(single["ColorName"]);
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
