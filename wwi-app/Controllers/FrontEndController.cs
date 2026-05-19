using Dapper;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Npgsql;
using System;
using System.Collections.Generic;
using System.Security.Claims;
using System.Threading.Tasks;

namespace wwi_app.Controllers
{
    public partial class FrontEndController : Controller
    {
        private readonly NpgsqlDataSource _db;
        private readonly ILogger _logger;

        public FrontEndController(NpgsqlDataSource db, ILogger<FrontEndController> logger)
        {
            _db = db;
            _logger = logger;
        }

        public async Task<IActionResult> Login(string username, string password)
        {
            if (string.IsNullOrEmpty(username))
                return Redirect("~/Index");

            bool isValidUser = false;
            var claims = new List<Claim> { new Claim(ClaimTypes.Email, username) };

            try
            {
                await using var conn = await _db.OpenConnectionAsync();
                var results = await conn.QueryAsync(
                    "SELECT * FROM webapi.login(@logon, @pwd)",
                    new { logon = username, pwd = password });

                foreach (var r in results)
                {
                    isValidUser = true;
                    var row = (IDictionary<string, object>)r;
                    claims.Add(new Claim(ClaimTypes.Sid, Convert.ToString(row["personid"])!));
                    claims.Add(new Claim(ClaimTypes.Name, Convert.ToString(row["preferredname"])!));
                    if (Convert.ToBoolean(row["issalesperson"]))
                        claims.Add(new Claim(ClaimTypes.Role, "Salesperson"));
                    if (Convert.ToBoolean(row["isemployee"]))
                        claims.Add(new Claim(ClaimTypes.Role, "Employee"));
                    if (row.TryGetValue("territory", out var territory) && territory != null)
                        claims.Add(new Claim("Territory", territory.ToString()!));
                }
            }
            catch (Exception e)
            {
                _logger.LogError(e, "Cannot login user: {Username}", username);
            }

            if (isValidUser)
            {
                var claimsIdentity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
                await HttpContext.SignInAsync(new ClaimsPrincipal(claimsIdentity));
                return Redirect("~/Dashboard");
            }

            _logger.LogWarning("Cannot login user: {Username}", username);
            return Redirect("~/Index");
        }

        public async Task<IActionResult> SignOut()
        {
            await HttpContext.SignOutAsync();
            return Redirect("~/Index");
        }

        public async Task Search(string name, string tag, double? minPrice, double? maxPrice, int? stockItemGroup, int top)
        {
            await using var conn = await _db.OpenConnectionAsync();
            // search_for_stock_items returns TABLE(result jsonb); cast to text to get the raw JSON string.
            var json = await conn.QueryFirstOrDefaultAsync<string>(
                "SELECT result::text FROM webapi.search_for_stock_items(@name, @tag, @minPrice, @maxPrice, @stockGroupId, @maxRows)",
                new
                {
                    name,
                    tag,
                    minPrice = (decimal?)minPrice,
                    maxPrice = (decimal?)maxPrice,
                    stockGroupId = stockItemGroup,
                    maxRows = top == 0 ? 20 : top
                });

            Response.ContentType = "application/json";
            await Response.WriteAsync(json ?? "{\"value\":[]}");
        }
    }
}
