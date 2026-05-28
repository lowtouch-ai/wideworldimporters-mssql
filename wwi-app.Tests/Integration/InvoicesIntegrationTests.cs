using Newtonsoft.Json.Linq;
using wwi_app.Tests.Fixtures;
using Xunit;

namespace wwi_app.Tests.Integration;

/// <summary>
/// Integration tests for the Invoices endpoints.
/// Hits the real postgres_15.1 Docker container.
///
/// Covers:
///   - TableController (DataTables paged reads from webapi.invoices view)
///   - ODataController (list and single-record fetch)
/// </summary>
[Trait("Category", "Integration")]
public class InvoicesIntegrationTests : IClassFixture<WwiWebAppFactory>
{
    private readonly HttpClient _client;

    public InvoicesIntegrationTests(WwiWebAppFactory factory)
    {
        _client = factory.CreateClient();
    }

    // ── Table endpoint (DataTables) ───────────────────────────────────────────

    [Fact]
    public async Task Table_Invoices_ReturnsNonEmptyData()
    {
        var json = await GetTableJson("/Table/Invoices?draw=1&start=0&length=10");

        var data = (JArray)json["data"]!;
        Assert.True(data.Count > 0, "Expected at least one invoice in the DB");
    }

    [Fact]
    public async Task Table_Invoices_ContainsExpectedColumns()
    {
        var json  = await GetTableJson("/Table/Invoices?draw=1&start=0&length=1");
        var first = (JObject)((JArray)json["data"]!).First!;

        // Columns from TableController.Invoices() → StreamTable call
        Assert.True(first.ContainsKey("InvoiceDate"),                   "Missing InvoiceDate");
        Assert.True(first.ContainsKey("CustomerPurchaseOrderNumber"),    "Missing CustomerPurchaseOrderNumber");
        Assert.True(first.ContainsKey("CustomerName"),                   "Missing CustomerName");
        Assert.True(first.ContainsKey("SalesPersonName"),                "Missing SalesPersonName");
        Assert.True(first.ContainsKey("InvoiceID"),                      "Missing InvoiceID");
    }

    [Fact]
    public async Task Table_Invoices_RecordsTotalMatchesFiltered_WhenNoSearch()
    {
        var json = await GetTableJson("/Table/Invoices?draw=1&start=0&length=5");

        Assert.Equal((long)json["recordsTotal"]!, (long)json["recordsFiltered"]!);
    }

    [Fact]
    public async Task Table_Invoices_Pagination_ReturnsCorrectPageSize()
    {
        var json = await GetTableJson("/Table/Invoices?draw=1&start=0&length=4");

        Assert.Equal(4, ((JArray)json["data"]!).Count);
    }

    [Fact]
    public async Task Table_Invoices_SecondPage_DifferentFromFirstPage()
    {
        var page1 = (JArray)(await GetTableJson("/Table/Invoices?draw=1&start=0&length=3"))["data"]!;
        var page2 = (JArray)(await GetTableJson("/Table/Invoices?draw=1&start=3&length=3"))["data"]!;

        if (page1.Count > 0 && page2.Count > 0)
            Assert.NotEqual(page1.First!["InvoiceID"]!.ToString(), page2.First!["InvoiceID"]!.ToString());
    }

    [Fact]
    public async Task Table_Invoices_Search_FiltersResults()
    {
        var allJson      = await GetTableJson("/Table/Invoices?draw=1&start=0&length=5");
        var totalRecords = (long)allJson["recordsTotal"]!;

        var searchJson = await GetTableJson("/Table/Invoices?draw=1&start=0&length=5&search[value]=ZZZNOMATCH_99999");
        Assert.Equal(0, (long)searchJson["recordsFiltered"]!);
        Assert.True(totalRecords > 0, "Total invoices should be > 0; seeded data missing?");
    }

    // ── OData endpoint ────────────────────────────────────────────────────────

    [Fact]
    public async Task OData_Invoices_List_ContainsInvoiceID()
    {
        var items = await GetODataValueArray("/OData/Invoices");

        Assert.True(items.Count > 0, "OData Invoices list is empty");
        Assert.NotNull(items.First!["InvoiceID"]);
    }

    [Fact]
    public async Task OData_Invoices_List_ContainsCustomerAndSalesFields()
    {
        var items = await GetODataValueArray("/OData/Invoices");
        var first = (JObject)items.First!;

        Assert.True(first.ContainsKey("CustomerName"),    "Missing CustomerName");
        Assert.True(first.ContainsKey("SalesPersonName"), "Missing SalesPersonName");
        Assert.True(first.ContainsKey("IsCreditNote"),    "Missing IsCreditNote");
    }

    [Fact]
    public async Task OData_Invoices_SingleRecord_MatchesListRecord()
    {
        var items = await GetODataValueArray("/OData/Invoices");
        var id    = (int)items.First!["InvoiceID"]!;

        var single = await GetODataObject($"/OData/Invoices({id})");
        Assert.Equal(id, (int)single["InvoiceID"]!);
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
