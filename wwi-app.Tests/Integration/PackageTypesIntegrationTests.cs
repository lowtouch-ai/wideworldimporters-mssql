using Newtonsoft.Json.Linq;
using wwi_app.Tests.Fixtures;
using Xunit;

namespace wwi_app.Tests.Integration;

/// <summary>
/// Integration tests for the PackageTypes endpoints.
/// Hits the real postgres_15.1 Docker container.
/// Prerequisite: docker-compose up (agentomatic stack) must be running.
///
/// Covers:
///   - ODataController  (full record list, single-record fetch)
/// </summary>
[Trait("Category", "Integration")]
public class PackageTypesIntegrationTests : IClassFixture<WwiWebAppFactory>
{
    private readonly HttpClient _client;

    public PackageTypesIntegrationTests(WwiWebAppFactory factory)
    {
        _client = factory.CreateClient();
    }

    // ── OData endpoint ────────────────────────────────────────────────────────

    [Fact]
    public async Task OData_PackageTypes_List_ReturnsNonEmptyData()
    {
        var response = await _client.GetAsync("/OData/PackageTypes");
        response.EnsureSuccessStatusCode();

        var json  = JObject.Parse(await response.Content.ReadAsStringAsync());
        var items = (JArray)json["value"]!;

        Assert.True(items.Count > 0, "OData PackageTypes list is empty");
    }

    [Fact]
    public async Task OData_PackageTypes_List_ContainsExpectedFields()
    {
        var items = await GetODataValueArray("/OData/PackageTypes");
        var first = (JObject)items.First!;

        Assert.True(first.ContainsKey("PackageTypeID"),   "Missing PackageTypeID");
        Assert.True(first.ContainsKey("PackageTypeName"), "Missing PackageTypeName");
    }

    [Fact]
    public async Task OData_PackageTypes_SingleRecord_MatchesListRecord()
    {
        var items  = await GetODataValueArray("/OData/PackageTypes");
        var id     = (int)items.First!["PackageTypeID"]!;
        var single = await GetODataObject($"/OData/PackageTypes({id})");

        Assert.Equal(id, (int)single["PackageTypeID"]!);
    }

    [Fact]
    public async Task OData_PackageTypes_SingleRecord_ContainsPackageTypeName()
    {
        var items  = await GetODataValueArray("/OData/PackageTypes");
        var id     = (int)items.First!["PackageTypeID"]!;
        var single = await GetODataObject($"/OData/PackageTypes({id})");

        Assert.NotNull(single["PackageTypeName"]);
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
