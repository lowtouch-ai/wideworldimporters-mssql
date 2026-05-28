using Newtonsoft.Json.Linq;
using wwi_app.Tests.Fixtures;
using Xunit;

namespace wwi_app.Tests.Integration;

/// <summary>
/// Integration tests for the SupplierCategories OData endpoint.
/// Hits the real postgres_15.1 Docker container.
/// Prerequisite: docker-compose up (agentomatic stack) must be running.
///
/// Note: No TableController endpoint exists for SupplierCategories — OData only.
/// </summary>
[Trait("Category", "Integration")]
public class SupplierCategoriesIntegrationTests : IClassFixture<WwiWebAppFactory>
{
    private readonly HttpClient _client;

    public SupplierCategoriesIntegrationTests(WwiWebAppFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task OData_SupplierCategories_List_ReturnsNonEmptyArray()
    {
        var items = await GetODataValueArray("/OData/SupplierCategories");
        Assert.True(items.Count > 0, "Expected at least one supplier category in the DB");
    }

    [Fact]
    public async Task OData_SupplierCategories_List_ContainsCoreFields()
    {
        var items = await GetODataValueArray("/OData/SupplierCategories");
        if (!items.Any()) return;

        var first = (JObject)items.First!;
        Assert.True(first.ContainsKey("SupplierCategoryID"),   "Missing SupplierCategoryID");
        Assert.True(first.ContainsKey("SupplierCategoryName"), "Missing SupplierCategoryName");
    }

    [Fact]
    public async Task OData_SupplierCategories_List_ContainsBothColumns()
    {
        var items = await GetODataValueArray("/OData/SupplierCategories");
        if (!items.Any()) return;

        var first    = (JObject)items.First!;
        var expected = new[] { "SupplierCategoryID", "SupplierCategoryName" };
        foreach (var col in expected)
            Assert.True(first.ContainsKey(col), $"Missing column: {col}");
    }

    [Fact]
    public async Task OData_SupplierCategories_SingleRecord_MatchesListRecord()
    {
        var items  = await GetODataValueArray("/OData/SupplierCategories");
        var id     = (int)items.First!["SupplierCategoryID"]!;
        var single = await GetODataObject($"/OData/SupplierCategories({id})");

        Assert.Equal(id, (int)single["SupplierCategoryID"]!);
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
