using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Npgsql;
using System;
using System.Collections.Generic;
using System.Security.Claims;
using System.Threading.Tasks;

namespace wwi_app.Controllers
{
    public partial class FrontEndController : Controller
    {
        private readonly NpgsqlDataSource _dataSource;
        private readonly ILogger _logger;

        public FrontEndController(NpgsqlDataSource dataSource, ILogger<FrontEndController> logger)
        {
            this._dataSource = dataSource;
            this._logger = logger;
        }

        public IActionResult Login(string returnUrl = "/Dashboard")
        {
            return Challenge(new AuthenticationProperties { RedirectUri = returnUrl },
                OpenIdConnectDefaults.AuthenticationScheme);
        }

        public async Task<IActionResult> SignOut()
        {
            await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
            await HttpContext.SignOutAsync(OpenIdConnectDefaults.AuthenticationScheme,
                new AuthenticationProperties { RedirectUri = "/Index" });
            return new EmptyResult();
        }

        public async Task Search(string name, string tag, double? minPrice, double? maxPrice, int? stockItemGroup, int top)
        {
            await using var conn = await _dataSource.OpenConnectionAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT webapi.search_for_stock_items($1::varchar, $2::varchar, $3::numeric, $4::numeric, $5::int, $6::int)";
            cmd.Parameters.AddWithValue(name as object ?? DBNull.Value);
            cmd.Parameters.AddWithValue(tag as object ?? DBNull.Value);
            cmd.Parameters.AddWithValue(minPrice as object ?? DBNull.Value);
            cmd.Parameters.AddWithValue(maxPrice as object ?? DBNull.Value);
            cmd.Parameters.AddWithValue(stockItemGroup as object ?? DBNull.Value);
            cmd.Parameters.AddWithValue(top <= 0 ? 20 : top);
            var result = await cmd.ExecuteScalarAsync();
            var json = result as string ?? "{\"value\":[]}";
            Response.ContentType = "application/json";
            await Response.WriteAsync(json);
        }
    }
}
