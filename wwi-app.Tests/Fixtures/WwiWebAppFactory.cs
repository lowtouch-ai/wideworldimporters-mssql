using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Npgsql;

namespace wwi_app.Tests.Fixtures;

/// <summary>
/// WebApplicationFactory for the legacy WebHostBuilder-based wwi-app.
/// Because Program.cs uses the old WebHostBuilder (not Generic Host), we can't use
/// WebApplicationFactory[Program] directly. Instead we build the host ourselves via
/// CreateWebHostBuilder and point it at the Docker Postgres container.
/// </summary>
public class WwiWebAppFactory : WebApplicationFactory<App.Startup>
{
    protected override IWebHostBuilder? CreateWebHostBuilder()
    {
        return new WebHostBuilder()
            .UseEnvironment("Testing")
            .UseContentRoot(GetContentRoot())
            .UseStartup<App.Startup>()
            .UseTestServer()
            .ConfigureServices(services =>
            {
                var descriptor = services.SingleOrDefault(d => d.ServiceType == typeof(NpgsqlDataSource));
                if (descriptor != null)
                    services.Remove(descriptor);

                var dataSource = new NpgsqlDataSourceBuilder(DockerPostgresFixture.ConnectionString).Build();
                services.AddSingleton(dataSource);
            });
    }

    private static string GetContentRoot()
    {
        // Walk up from test assembly location to find the wwi-app folder
        var dir = new DirectoryInfo(AppContext.BaseDirectory);
        while (dir != null && !Directory.Exists(Path.Combine(dir.FullName, "wwi-app")))
            dir = dir.Parent;
        return dir != null ? Path.Combine(dir.FullName, "wwi-app") : AppContext.BaseDirectory;
    }
}
