using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.DependencyInjection;
using Npgsql;

var host = new HostBuilder()
    .ConfigureFunctionsWorkerDefaults()
    .ConfigureServices(services =>
    {
        var connectionString = Environment.GetEnvironmentVariable("SqlDb")
            ?? throw new InvalidOperationException("SqlDb connection string not set.");
        services.AddNpgsqlDataSource(connectionString);
    })
    .Build();

host.Run();
