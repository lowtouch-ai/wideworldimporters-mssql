using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Npgsql;

namespace App
{
    public class Startup
    {
        public Startup(IWebHostEnvironment env)
        {
            var builder = new ConfigurationBuilder()
                .SetBasePath(env.ContentRootPath)
                .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
                .AddJsonFile($"appsettings.{env.EnvironmentName}.json", optional: true)
                .AddEnvironmentVariables();
            Configuration = builder.Build();
        }

        public IConfigurationRoot Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddSingleton<IHttpContextAccessor, HttpContextAccessor>();

            services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
                        .AddCookie(o =>
                            {
                                o.LoginPath = new PathString("/Index");
                                o.AccessDeniedPath = new PathString("/Index");
                            }
                        );

            var connStr = Configuration["ConnectionStrings:WWI"];
            var dataSource = new NpgsqlDataSourceBuilder(connStr).Build();
            services.AddSingleton(dataSource);

            services.AddAuthorization();

            // Add framework services.
            services.AddMvc(o => o.EnableEndpointRouting = false);
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                app.UseExceptionHandler("/Error");
            }

            app.UseStaticFiles();
            app.UseAuthentication();

            app.UseMvc(routes =>
            {
                routes.MapRoute(
                    "FrontEnd",
                    "{action}",
                    new { controller = "FrontEnd", action = "Index" }
                );

                routes.MapRoute(
                    "Api",
                    "{controller}/{action}"
                );

                routes.MapRoute(
                   "odata-single",
                   "OData/{action}({id})",
                   new { controller = "OData" }
                );
            });
        }
    }
}
