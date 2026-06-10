using Newtonsoft.Json.Linq;
using wwi_app.Tests.Fixtures;
using Xunit;

namespace wwi_app.Tests.Integration;

/// <summary>
/// Integration tests for the CustomerTransactions endpoints.
/// Hits the real postgres_15.1 Docker container.
///
/// Covers:
///   - TableController (DataTables paged reads from webapi.customer_transactions view)
///   - ODataController (list and single-record fetch)
/// </summary>
[Trait("Category", "Integration")]
public class CustomerTransactionsIntegrationTests : IClassFixture<WwiWebAppFactory>
{
    private readonly HttpClient _client;

    public CustomerTransactionsIntegrationTests(WwiWebAppFactory factory)
    {
        _client = factory.CreateClient();
    }

    // ── Table endpoint (DataTables) ───────────────────────────────────────────

    [Fact]
    public async Task Table_CustomerTransactions_ReturnsNonEmptyData()
    {
        var json = await GetTableJson("/Table/CustomerTransactions?draw=1&start=0&length=10");

        var data = (JArray)json["data"]!;
        Assert.True(data.Count > 0, "Expected at least one customer transaction in the DB");
    }

    [Fact]
    public async Task Table_CustomerTransactions_ContainsExpectedColumns()
    {
        var json  = await GetTableJson("/Table/CustomerTransactions?draw=1&start=0&length=1");
        var first = (JObject)((JArray)json["data"]!).First!;

        // Columns from TableController.CustomerTransactions() → StreamTable call
        Assert.True(first.ContainsKey("TransactionDate"),     "Missing TransactionDate");
        Assert.True(first.ContainsKey("TransactionAmount"),   "Missing TransactionAmount");
        Assert.True(first.ContainsKey("IsFinalized"),         "Missing IsFinalized");
        Assert.True(first.ContainsKey("CustomerName"),        "Missing CustomerName");
        Assert.True(first.ContainsKey("CustomerTransactionID"), "Missing CustomerTransactionID");
    }

    [Fact]
    public async Task Table_CustomerTransactions_RecordsTotalMatchesFiltered_WhenNoSearch()
    {
        var json = await GetTableJson("/Table/CustomerTransactions?draw=1&start=0&length=5");

        Assert.Equal((long)json["recordsTotal"]!, (long)json["recordsFiltered"]!);
    }

    [Fact]
    public async Task Table_CustomerTransactions_Pagination_ReturnsCorrectPageSize()
    {
        var json = await GetTableJson("/Table/CustomerTransactions?draw=1&start=0&length=4");

        Assert.Equal(4, ((JArray)json["data"]!).Count);
    }

    [Fact]
    public async Task Table_CustomerTransactions_SecondPage_DifferentFromFirstPage()
    {
        var page1 = (JArray)(await GetTableJson("/Table/CustomerTransactions?draw=1&start=0&length=3"))["data"]!;
        var page2 = (JArray)(await GetTableJson("/Table/CustomerTransactions?draw=1&start=3&length=3"))["data"]!;

        if (page1.Count > 0 && page2.Count > 0)
            Assert.NotEqual(
                page1.First!["CustomerTransactionID"]!.ToString(),
                page2.First!["CustomerTransactionID"]!.ToString());
    }

    [Fact]
    public async Task Table_CustomerTransactions_Search_FiltersResults()
    {
        var allJson      = await GetTableJson("/Table/CustomerTransactions?draw=1&start=0&length=5");
        var totalRecords = (long)allJson["recordsTotal"]!;

        var searchJson = await GetTableJson("/Table/CustomerTransactions?draw=1&start=0&length=5&search[value]=ZZZNOMATCH_99999");
        Assert.Equal(0, (long)searchJson["recordsFiltered"]!);
        Assert.True(totalRecords > 0, "Total customer transactions should be > 0; seeded data missing?");
    }

    // ── OData endpoint ────────────────────────────────────────────────────────

    [Fact]
    public async Task OData_CustomerTransactions_List_ContainsTransactionID()
    {
        var items = await GetODataValueArray("/OData/CustomerTransactions");

        Assert.True(items.Count > 0, "OData CustomerTransactions list is empty");
        Assert.NotNull(items.First!["CustomerTransactionID"]);
    }

    [Fact]
    public async Task OData_CustomerTransactions_List_ContainsFinancialFields()
    {
        var items = await GetODataValueArray("/OData/CustomerTransactions");
        var first = (JObject)items.First!;

        Assert.True(first.ContainsKey("AmountExcludingTax"),  "Missing AmountExcludingTax");
        Assert.True(first.ContainsKey("TaxAmount"),           "Missing TaxAmount");
        Assert.True(first.ContainsKey("TransactionAmount"),   "Missing TransactionAmount");
        Assert.True(first.ContainsKey("OutstandingBalance"),  "Missing OutstandingBalance");
        Assert.True(first.ContainsKey("IsFinalized"),         "Missing IsFinalized");
    }

    [Fact]
    public async Task OData_CustomerTransactions_SingleRecord_MatchesListRecord()
    {
        var items = await GetODataValueArray("/OData/CustomerTransactions");
        var id    = (int)items.First!["CustomerTransactionID"]!;

        var single = await GetODataObject($"/OData/CustomerTransactions({id})");
        Assert.Equal(id, (int)single["CustomerTransactionID"]!);
    }

    [Fact]
    public async Task OData_CustomerTransactions_TransactionAmount_IsNumeric()
    {
        var items = await GetODataValueArray("/OData/CustomerTransactions");

        foreach (var item in items.Take(5))
        {
            var amount = item["TransactionAmount"];
            Assert.NotNull(amount);
            Assert.True(
                amount!.Type == JTokenType.Float || amount.Type == JTokenType.Integer,
                $"TransactionAmount should be numeric, got {amount.Type}");
        }
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
