using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Protocols.OpenIdConnect;
using Npgsql;
using System;
using System.Security.Claims;
using System.Threading.Tasks;

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

        public void ConfigureServices(IServiceCollection services)
        {
            services.AddSingleton<IHttpContextAccessor, HttpContextAccessor>();

            var connStr = Configuration["ConnectionStrings:WWI"];
            var dataSource = new NpgsqlDataSourceBuilder(connStr).Build();
            services.AddSingleton(dataSource);

            services.AddAuthentication(options =>
            {
                options.DefaultScheme = CookieAuthenticationDefaults.AuthenticationScheme;
                options.DefaultChallengeScheme = OpenIdConnectDefaults.AuthenticationScheme;
            })
            .AddCookie(o =>
            {
                o.LoginPath = new PathString("/Login");
                o.AccessDeniedPath = new PathString("/Index");
            })
            .AddOpenIdConnect(options =>
            {
                options.Authority = Configuration["Keycloak:Authority"];
                options.ClientId = Configuration["Keycloak:ClientId"];
                options.ResponseType = OpenIdConnectResponseType.Code;
                options.CallbackPath = Configuration["Keycloak:CallbackPath"];
                options.SaveTokens = true;
                options.GetClaimsFromUserInfoEndpoint = true;
                options.RequireHttpsMetadata = true;

                // After Keycloak authenticates, enrich claims from the application DB
                options.CorrelationCookie.SameSite = SameSiteMode.Unspecified;
                options.CorrelationCookie.SecurePolicy = CookieSecurePolicy.None;
                options.NonceCookie.SameSite = SameSiteMode.Unspecified;
                options.NonceCookie.SecurePolicy = CookieSecurePolicy.None;

                var redirectUri = Configuration["Keycloak:RedirectUri"];
                options.Events = new OpenIdConnectEvents
                {
                    OnRedirectToIdentityProvider = ctx =>
                    {
                        if (!string.IsNullOrEmpty(redirectUri))
                            ctx.ProtocolMessage.RedirectUri = redirectUri;
                        return Task.CompletedTask;
                    },
                    OnTokenValidated = async ctx =>
                    {
                        var email = ctx.Principal?.FindFirstValue(ClaimTypes.Email)
                                    ?? ctx.Principal?.FindFirstValue("email");
                        if (string.IsNullOrEmpty(email)) return;

                        var ds = ctx.HttpContext.RequestServices.GetRequiredService<NpgsqlDataSource>();
                        var extraClaims = new System.Collections.Generic.List<Claim>();
                        try
                        {
                            await using var conn = await ds.OpenConnectionAsync();
                            await using var cmd = conn.CreateCommand();
                            cmd.CommandText = "SELECT * FROM webapi.login($1, $2)";
                            cmd.Parameters.AddWithValue(email);
                            cmd.Parameters.AddWithValue(string.Empty);
                            await using var reader = await cmd.ExecuteReaderAsync();
                            while (await reader.ReadAsync())
                            {
                                extraClaims.Add(new Claim(ClaimTypes.Sid, Convert.ToString(reader["personid"])));
                                extraClaims.Add(new Claim(ClaimTypes.Name, Convert.ToString(reader["preferredname"])));
                                if (reader["issalesperson"] != DBNull.Value && Convert.ToBoolean(reader["issalesperson"]))
                                    extraClaims.Add(new Claim(ClaimTypes.Role, "Salesperson"));
                                if (reader["isemployee"] != DBNull.Value && Convert.ToBoolean(reader["isemployee"]))
                                    extraClaims.Add(new Claim(ClaimTypes.Role, "Employee"));
                                if (reader["territory"] != DBNull.Value)
                                    extraClaims.Add(new Claim("Territory", reader["territory"].ToString()));
                            }
                        }
                        catch { /* user not in WWI DB — still authenticated via Keycloak */ }

                        if (extraClaims.Count > 0)
                            ctx.Principal.AddIdentity(new ClaimsIdentity(extraClaims));
                    }
                };
            });

            services.AddAuthorization();
            services.AddMvc(o => o.EnableEndpointRouting = false);
        }

        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
                app.UseDeveloperExceptionPage();
            else
                app.UseExceptionHandler("/Error");

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
