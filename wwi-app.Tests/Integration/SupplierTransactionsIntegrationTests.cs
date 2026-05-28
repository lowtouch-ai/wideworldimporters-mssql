using Newtonsoft.Json.Linq;
using wwi_app.Tests.Fixtures;
using Xunit;

namespace wwi_app.Tests.Integration;

/// <summary>
/// Integration tests for the SupplierTransactions OData endpoint.
/// Hits the real postgres_15.1 Docker container.
/// Prerequisite: docker-compose up (agentomatic stack) must be running.
///
/// Note: No TableController endpoint exists for SupplierTransactions — OData only.
/// </summary>
[Trait("Category", "Integration")]
public class SupplierTransactionsIntegrationTests : IClassFixture<WwiWebAppFactory>
{
    private readonly HttpClient _client;

    public SupplierTransactionsIntegrationTests(WwiWebAppFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task OData_SupplierTransactions_List_ReturnsNonEmptyArray()
    {
        var items = await GetODataValueArray("/OData/SupplierTransactions");
        Assert.True(items.Count > 0, "Expected at least one supplier transaction in the DB");
    }

    [Fact]
    public async Task OData_SupplierTransactions_List_ContainsCoreFields()
    {
        var items = await GetODataValueArray("/OData/SupplierTransactions");
        if (!items.Any()) return;

        var first = (JObject)items.First!;
        Assert.True(first.ContainsKey("SupplierTransactionID"), "Missing SupplierTransactionID");
        Assert.True(first.ContainsKey("TransactionDate"),       "Missing TransactionDate");
        Assert.True(first.ContainsKey("TransactionAmount"),     "Missing TransactionAmount");
        Assert.True(first.ContainsKey("SupplierName"),          "Missing SupplierName");
    }

    [Fact]
    public async Task OData_SupplierTransactions_List_ContainsAll15Columns()
    {
        var items = await GetODataValueArray("/OData/SupplierTransactions");
        if (!items.Any()) return;

        var first    = (JObject)items.First!;
        var expected = new[]
        {
            "SupplierTransactionID", "TransactionDate", "AmountExcludingTax", "TaxAmount",
            "TransactionAmount", "OutstandingBalance", "FinalizationDate", "IsFinalized",
            "SupplierName", "TransactionTypeName", "PaymentMethodName",
            "SupplierID", "TransactionTypeID", "PurchaseOrderID", "PaymentMethodID"
        };
        foreach (var col in expected)
            Assert.True(first.ContainsKey(col), $"Missing column: {col}");
    }

    [Fact]
    public async Task OData_SupplierTransactions_SingleRecord_MatchesListRecord()
    {
        var items  = await GetODataValueArray("/OData/SupplierTransactions");
        var id     = (int)items.First!["SupplierTransactionID"]!;
        var single = await GetODataObject($"/OData/SupplierTransactions({id})");

        Assert.Equal(id, (int)single["SupplierTransactionID"]!);
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
