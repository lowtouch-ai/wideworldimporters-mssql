using Newtonsoft.Json.Linq;
using wwi_app.Tests.Fixtures;
using Xunit;

namespace wwi_app.Tests.Integration;

/// <summary>
/// Integration tests for the TransactionTypes OData endpoint.
/// Hits the real postgres_15.1 Docker container.
/// Prerequisite: docker-compose up (agentomatic stack) must be running.
///
/// Note: No TableController endpoint exists for TransactionTypes — OData only.
/// </summary>
[Trait("Category", "Integration")]
public class TransactionTypesIntegrationTests : IClassFixture<WwiWebAppFactory>
{
    private readonly HttpClient _client;

    public TransactionTypesIntegrationTests(WwiWebAppFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task OData_TransactionTypes_List_ReturnsNonEmptyArray()
    {
        var items = await GetODataValueArray("/OData/TransactionTypes");
        Assert.True(items.Count > 0, "Expected at least one transaction type in the DB");
    }

    [Fact]
    public async Task OData_TransactionTypes_List_ContainsCoreFields()
    {
        var items = await GetODataValueArray("/OData/TransactionTypes");
        if (!items.Any()) return;

        var first = (JObject)items.First!;
        Assert.True(first.ContainsKey("TransactionTypeID"),   "Missing TransactionTypeID");
        Assert.True(first.ContainsKey("TransactionTypeName"), "Missing TransactionTypeName");
    }

    [Fact]
    public async Task OData_TransactionTypes_List_ContainsBothColumns()
    {
        var items = await GetODataValueArray("/OData/TransactionTypes");
        if (!items.Any()) return;

        var first    = (JObject)items.First!;
        var expected = new[] { "TransactionTypeID", "TransactionTypeName" };
        foreach (var col in expected)
            Assert.True(first.ContainsKey(col), $"Missing column: {col}");
    }

    [Fact]
    public async Task OData_TransactionTypes_SingleRecord_MatchesListRecord()
    {
        var items  = await GetODataValueArray("/OData/TransactionTypes");
        var id     = (int)items.First!["TransactionTypeID"]!;
        var single = await GetODataObject($"/OData/TransactionTypes({id})");

        Assert.Equal(id, (int)single["TransactionTypeID"]!);
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
