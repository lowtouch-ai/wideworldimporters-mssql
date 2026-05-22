using Newtonsoft.Json.Linq;
using wwi_app.Tests.Fixtures;
using Xunit;

namespace wwi_app.Tests.Integration;

/// <summary>
/// Integration tests for the SpecialDeals OData endpoint.
/// Hits the real postgres_15.1 Docker container.
/// Prerequisite: docker-compose up (agentomatic stack) must be running.
///
/// Note: No TableController endpoint exists for SpecialDeals — OData only.
/// </summary>
[Trait("Category", "Integration")]
public class SpecialDealsIntegrationTests : IClassFixture<WwiWebAppFactory>
{
    private readonly HttpClient _client;

    public SpecialDealsIntegrationTests(WwiWebAppFactory factory)
    {
        _client = factory.CreateClient();
    }

    // ── OData list ───────────────────────────────────────────────────────────

    [Fact]
    public async Task OData_SpecialDeals_List_ReturnsNonEmptyArray()
    {
        var items = await GetODataValueArray("/OData/SpecialDeals");

        Assert.True(items.Count > 0, "Expected at least one special deal in the DB");
    }

    [Fact]
    public async Task OData_SpecialDeals_List_ContainsCoreFields()
    {
        var items = await GetODataValueArray("/OData/SpecialDeals");
        if (!items.Any()) return;

        var first = (JObject)items.First!;
        Assert.True(first.ContainsKey("SpecialDealID"),   "Missing SpecialDealID");
        Assert.True(first.ContainsKey("DealDescription"), "Missing DealDescription");
        Assert.True(first.ContainsKey("StartDate"),       "Missing StartDate");
        Assert.True(first.ContainsKey("EndDate"),         "Missing EndDate");
    }

    [Fact]
    public async Task OData_SpecialDeals_List_ContainsAll18Columns()
    {
        var items = await GetODataValueArray("/OData/SpecialDeals");
        if (!items.Any()) return;

        var first    = (JObject)items.First!;
        var expected = new[]
        {
            "SpecialDealID","DealDescription","StartDate","EndDate",
            "DiscountAmount","DiscountPercentage","UnitPrice",
            "StockItemName","Brand","Size",
            "CustomerName","BuyingGroupName","CustomerCategoryName",
            "StockItemID","CustomerID","BuyingGroupID","CustomerCategoryID","StockGroupID"
        };
        foreach (var col in expected)
            Assert.True(first.ContainsKey(col), $"Missing column: {col}");
    }

    [Fact]
    public async Task OData_SpecialDeals_List_NumericDiscountFieldsAreNullOrNumeric()
    {
        var items = await GetODataValueArray("/OData/SpecialDeals");
        if (!items.Any()) return;

        foreach (JObject item in items.Take(5))
        {
            foreach (var field in new[] { "DiscountAmount", "DiscountPercentage", "UnitPrice" })
            {
                var token = item[field];
                Assert.True(
                    token == null
                    || token.Type == JTokenType.Null
                    || token.Type == JTokenType.Float
                    || token.Type == JTokenType.Integer,
                    $"Row has non-numeric {field}: {token}");
            }
        }
    }

    [Fact]
    public async Task OData_SpecialDeals_List_RelationalNameFieldsAreNullOrString()
    {
        var items = await GetODataValueArray("/OData/SpecialDeals");
        if (!items.Any()) return;

        foreach (JObject item in items.Take(5))
        {
            foreach (var field in new[] { "CustomerName", "BuyingGroupName", "CustomerCategoryName", "StockItemName" })
            {
                var token = item[field];
                Assert.True(
                    token == null
                    || token.Type == JTokenType.Null
                    || token.Type == JTokenType.String,
                    $"Row has non-string {field}: {token}");
            }
        }
    }

    // ── OData single-record ───────────────────────────────────────────────────

    [Fact]
    public async Task OData_SpecialDeals_SingleRecord_MatchesListRecord()
    {
        var items  = await GetODataValueArray("/OData/SpecialDeals");
        if (!items.Any()) return;

        var id     = (int)items.First!["SpecialDealID"]!;
        var single = await GetODataObject($"/OData/SpecialDeals({id})");

        Assert.Equal(id, (int)single["SpecialDealID"]!);
    }

    [Fact]
    public async Task OData_SpecialDeals_SingleRecord_ContainsAll18Columns()
    {
        var items = await GetODataValueArray("/OData/SpecialDeals");
        if (!items.Any()) return;

        var id     = (int)items.First!["SpecialDealID"]!;
        var single = await GetODataObject($"/OData/SpecialDeals({id})");

        var expected = new[]
        {
            "SpecialDealID","DealDescription","StartDate","EndDate",
            "DiscountAmount","DiscountPercentage","UnitPrice",
            "StockItemName","Brand","Size",
            "CustomerName","BuyingGroupName","CustomerCategoryName",
            "StockItemID","CustomerID","BuyingGroupID","CustomerCategoryID","StockGroupID"
        };
        foreach (var col in expected)
            Assert.True(single.ContainsKey(col), $"Missing column in single-record response: {col}");
    }

    [Fact]
    public async Task OData_SpecialDeals_NonExistentId_Returns200()
    {
        var response = await _client.GetAsync("/OData/SpecialDeals(99999999)");

        Assert.Equal(System.Net.HttpStatusCode.OK, response.StatusCode);
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
