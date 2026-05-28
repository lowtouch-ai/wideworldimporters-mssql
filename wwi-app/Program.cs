using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Http;
using Npgsql;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddSingleton<IHttpContextAccessor, HttpContextAccessor>();

builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(o =>
    {
        o.LoginPath = "/Index";
        o.AccessDeniedPath = "/Index";
    });

var connectionString = builder.Configuration.GetConnectionString("WWI")!;
builder.Services.AddNpgsqlDataSource(connectionString);

builder.Services.AddAuthorization();
builder.Services.AddControllersWithViews();

var app = builder.Build();

if (app.Environment.IsDevelopment())
    app.UseDeveloperExceptionPage();
else
    app.UseExceptionHandler("/Error");

app.UseStaticFiles();
app.UseAuthentication();
app.UseAuthorization();

app.MapControllerRoute("FrontEnd", "{action}", new { controller = "FrontEnd", action = "Index" });
app.MapControllerRoute("Api", "{controller}/{action}");
app.MapControllerRoute("odata-single", "OData/{action}({id})", new { controller = "OData" });

app.Run();
