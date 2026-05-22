using Newtonsoft.Json.Linq;
using wwi_app.Tests.Fixtures;
using Xunit;

namespace wwi_app.Tests.Integration;

/// <summary>
/// Integration tests for the Suppliers OData endpoint.
/// Hits the real postgres_15.1 Docker container.
/// Prerequisite: docker-compose up (agentomatic stack) must be running.
///
/// Note: No TableController endpoint exists for Suppliers — OData only.
/// </summary>
[Trait("Category", "Integration")]
public class SuppliersIntegrationTests : IClassFixture<WwiWebAppFactory>
{
    private readonly HttpClient _client;

    public SuppliersIntegrationTests(WwiWebAppFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task OData_Suppliers_List_ReturnsNonEmptyArray()
    {
        var items = await GetODataValueArray("/OData/Suppliers");
        Assert.True(items.Count > 0, "Expected at least one supplier in the DB");
    }

    [Fact]
    public async Task OData_Suppliers_List_ContainsCoreFields()
    {
        var items = await GetODataValueArray("/OData/Suppliers");
        if (!items.Any()) return;

        var first = (JObject)items.First!;
        Assert.True(first.ContainsKey("SupplierID"),           "Missing SupplierID");
        Assert.True(first.ContainsKey("SupplierName"),         "Missing SupplierName");
        Assert.True(first.ContainsKey("SupplierCategoryName"), "Missing SupplierCategoryName");
        Assert.True(first.ContainsKey("PaymentDays"),          "Missing PaymentDays");
    }

    [Fact]
    public async Task OData_Suppliers_List_ContainsAll19Columns()
    {
        var items = await GetODataValueArray("/OData/Suppliers");
        if (!items.Any()) return;

        var first    = (JObject)items.First!;
        var expected = new[]
        {
            "SupplierID", "SupplierName", "SupplierCategoryName", "PrimaryContact",
            "AlternateContact", "PhoneNumber", "FaxNumber", "WebsiteURL",
            "SupplierReference", "BankAccountName", "BankAccountBranch",
            "BankAccountCode", "BankAccountNumber", "BankInternationalCode",
            "PostalAddressLine1", "PostalAddressLine2", "PostalPostalCode",
            "PaymentDays", "SupplierCategoryID"
        };
        foreach (var col in expected)
            Assert.True(first.ContainsKey(col), $"Missing column: {col}");
    }

    [Fact]
    public async Task OData_Suppliers_SingleRecord_MatchesListRecord()
    {
        var items  = await GetODataValueArray("/OData/Suppliers");
        var id     = (int)items.First!["SupplierID"]!;
        var single = await GetODataObject($"/OData/Suppliers({id})");

        Assert.Equal(id, (int)single["SupplierID"]!);
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
