# Frontend Bug Fix Report

**Date:** 2026-05-28  
**Author:** Anugrah P (`aprathap@ecloudcontrol.com`)  
**Source:** `frontend/test-report.md` (7 bugs reported on wwi2025b.lowtouch.ai)

---

## Bug Summary & Attribution

| # | Bug | Layer | Introduced By | Fix Applied |
|---|-----|-------|--------------|-------------|
| 1 | State/Province blank in Cities table | Backend | **Anugrah P** (commit `529c501`) | ✅ |
| 2 | Country blank in StateProvinces table | Backend | **Anugrah P** (commit `529c501`) | ✅ |
| 3 | Delete has no confirmation dialog | Frontend | Pre-existing (original MS sample) | ✅ |
| 4 | CRUD modals missing `required` validation | Frontend | Pre-existing (original MS sample) | ✅ |
| 5 | Product Size always blank | Data | Pre-existing (original MS sample) | ✅ |
| 6 | Dashboard "All region" label incorrect | Frontend | Pre-existing (original MS sample) | ✅ |
| 7 | Category filters vanish after search | Frontend | Pre-existing (original MS sample) | ✅ |

**Ajay Raj-C had no involvement in any of the 7 bugs.**

---

## Root Cause Analysis

### Bugs 1 & 2 — Introduced by Migration (Anugrah P, commit `529c501`)

The original MSSQL app used `Belgrade.SqlClient` `TableSpec` objects that called MSSQL stored procedures (e.g., `WebApi.Cities`, `WebApi.StateProvinces`). Those stored procedures internally JOINed related tables and returned `StateProvinceName` and `CountryName` as part of their result sets.

During the **Session 19 migration** to PostgreSQL (`529c501` — "Session 19: migrate application code from MSSQL to PostgreSQL", May 19 2026), `ODataController.cs` was rewritten to use raw Npgsql SQL. The column list was copied literally from the `TableSpec` definition — which only listed the base table columns — losing the implicitly joined names.

The PostgreSQL `webapi.cities` and `webapi.state_provinces` views **already had the correct JOINs** providing `StateProvinceName` and `CountryName`; the raw SQL simply wasn't SELECTing them.

**Fix:** Added the missing columns to the SELECT list in `ODataController.cs`:
- Cities query: added `StateProvinceName`
- StateProvinces query: added `CountryName`

### Bugs 3–7 — Pre-existing in Original Microsoft Sample

These bugs were present since commit `11f770c` ("Add WideWorldImporters MSSQL sample database", Feb 2026) — before any migration work by Anugrah or Ajay.

- **Bug 3 (no delete confirmation):** `.remove().save()` fired without any guard in all 14 CRUD JS files.
- **Bug 4 (missing `required`):** HTML modal inputs lacked the `required` attribute across 10 Razor views.
- **Bug 5 (Size always blank):** `Size` column is NULL for all rows in the WideWorldImporters sample dataset — the column exists, the data simply was never populated. The UI now conditionally hides the Size label when empty.
- **Bug 6 (Dashboard label):** Hardcoded `"All"` + `"region"` split across template and JS instead of a single fallback string.
- **Bug 7 (category filters vanish):** `webapi.search_for_stock_items` uses `json_agg` for tags, which returns SQL `NULL` (not `[]`) when no rows match. The JS `refresh()` function did not guard against `null`, causing a TypeError that prevented re-rendering the tag buttons after a name-filtered search.

---

## Files Changed

### Backend
- `wwi-app/Controllers/ODataController.cs` — added `StateProvinceName` / `CountryName` to Cities and StateProvinces SELECT queries

### Frontend — Views (added `required` to modal inputs)
- `wwi-app/Views/FrontEnd/BuyingGroups.cshtml`
- `wwi-app/Views/FrontEnd/Cities.cshtml`
- `wwi-app/Views/FrontEnd/Colors.cshtml`
- `wwi-app/Views/FrontEnd/Countries.cshtml`
- `wwi-app/Views/FrontEnd/CustomerCategories.cshtml`
- `wwi-app/Views/FrontEnd/Dashboard.cshtml` — fixed "all regions" fallback label
- `wwi-app/Views/FrontEnd/Offers.cshtml` — hide empty Size, fix category filter re-render
- `wwi-app/Views/FrontEnd/PackageTypes.cshtml`
- `wwi-app/Views/FrontEnd/StateProvinces.cshtml`
- `wwi-app/Views/FrontEnd/StockGroups.cshtml`
- `wwi-app/Views/FrontEnd/SupplierCategories.cshtml`
- `wwi-app/Views/FrontEnd/TransactionTypes.cshtml`

### Frontend — JavaScript (added delete confirmation)
- `wwi-app/wwwroot/js/BuyingGroups.js`
- `wwi-app/wwwroot/js/Cities.js`
- `wwi-app/wwwroot/js/Colors.js`
- `wwi-app/wwwroot/js/Countries.js`
- `wwi-app/wwwroot/js/CustomerCategories.js`
- `wwi-app/wwwroot/js/Deals.js`
- `wwi-app/wwwroot/js/DeliveryMethods.js`
- `wwi-app/wwwroot/js/PackageTypes.js`
- `wwi-app/wwwroot/js/PaymentMethods.js`
- `wwi-app/wwwroot/js/StateProvinces.js`
- `wwi-app/wwwroot/js/StockGroups.js`
- `wwi-app/wwwroot/js/StockItems.Edit.js`
- `wwi-app/wwwroot/js/SupplierCategories.js`
- `wwi-app/wwwroot/js/TransactionTypes.js`
