using Npgsql;
using Xunit;

namespace wwi_app.Tests.Fixtures;

/// <summary>
/// Shared fixture that opens a real connection to the postgres_15.1 Docker container.
/// Requires: docker-compose up wwi-app (or the agentomatic stack) to be running.
/// Connection: Host=localhost;Port=5432;Database=postgres;Username=postgres;Password=postgres
/// </summary>
public class DockerPostgresFixture : IAsyncLifetime
{
    // Default: bridge IP for WSL2 host runs.
    // Override via POSTGRES_TEST_HOST env var (e.g. "postgres_15.1" when running inside Docker).
    public static readonly string ConnectionString =
        $"Host={Environment.GetEnvironmentVariable("POSTGRES_TEST_HOST") ?? "172.19.0.8"};" +
        "Port=5432;Database=postgres;Username=postgres;Password=postgres";

    public NpgsqlDataSource DataSource { get; private set; } = null!;

    public async Task InitializeAsync()
    {
        DataSource = new NpgsqlDataSourceBuilder(ConnectionString).Build();
        // Verify connectivity — throws if the container isn't running
        await using var conn = await DataSource.OpenConnectionAsync();
    }

    public async Task DisposeAsync()
    {
        await DataSource.DisposeAsync();
    }
}
