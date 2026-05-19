using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
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

        public async Task<IActionResult> Login(string username, string password)
        {
            if (string.IsNullOrEmpty(username))
            {
                return Redirect("~/Index");
            }

            bool isValidUser = false;
            var claims = new List<Claim>() { new Claim(ClaimTypes.Email, username) };

            try
            {
                await using var conn = await _dataSource.OpenConnectionAsync();
                await using var cmd = conn.CreateCommand();
                cmd.CommandText = "SELECT * FROM webapi.login($1, $2)";
                cmd.Parameters.AddWithValue(username);
                cmd.Parameters.AddWithValue(password);
                await using var reader = await cmd.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    isValidUser = true;
                    claims.Add(new Claim(ClaimTypes.Sid, Convert.ToString(reader["personid"])));
                    claims.Add(new Claim(ClaimTypes.Name, Convert.ToString(reader["preferredname"])));
                    if (reader["issalesperson"] != DBNull.Value && Convert.ToBoolean(reader["issalesperson"]))
                        claims.Add(new Claim(ClaimTypes.Role, "Salesperson"));
                    if (reader["isemployee"] != DBNull.Value && Convert.ToBoolean(reader["isemployee"]))
                        claims.Add(new Claim(ClaimTypes.Role, "Employee"));
                    if (reader["territory"] != DBNull.Value && reader["territory"] != null)
                        claims.Add(new Claim("Territory", reader["territory"].ToString()));
                }
            }
            catch (Exception e)
            {
                _logger.LogError(e, "Cannot login user:" + username);
            }

            if (isValidUser)
            {
                var claimsIdentity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
                await HttpContext.SignInAsync(new ClaimsPrincipal(claimsIdentity));
                return Redirect("~/Dashboard");
            }
            else
            {
                _logger.LogWarning("Cannot login user: " + username);
            }
            return Redirect("~/Index");
        }

        public async Task<IActionResult> SignOut()
        {
            await HttpContext.SignOutAsync();
            return Redirect("~/Index");
        }

        public async Task Search(string name, string tag, double? minPrice, double? maxPrice, int? stockItemGroup, int top)
        {
            await using var conn = await _dataSource.OpenConnectionAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT webapi.search_for_stock_items($1, $2, $3, $4, $5, $6)";
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
