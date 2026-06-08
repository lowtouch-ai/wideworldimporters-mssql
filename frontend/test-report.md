# Frontend Test Report — wwi2025b.lowtouch.ai

**Date:** 2026-05-28  
**Tester:** Claude Code (automated browser testing)  
**App:** Wide World Importers — ASP.NET Core MVC + OData + DataTables  
**Auth:** OpenID Connect via Keycloak (`auth2025.lowtouch.ai`)

---

## Coverage

All 21 nav pages tested + Dashboard + auth flow.

---

## ✅ Working Correctly

| Area | Result |
|---|---|
| **Homepage** | Carousel, tech links, footer — all render |
| **Auth** | OpenID Connect via Keycloak — redirects correctly |
| **Dashboard** | 4 charts load with live data (D3/NVD3): sales timeline, top cities, color pie, income donut |
| **Sales Orders** | Master-detail table: orders + order lines. Edit loads row data |
| **Invoices** | 10 rows, correct columns |
| **Customer Transactions** | 10 rows, correct columns |
| **Customers** | Rich master-detail: customers + orders + order lines + transactions + invoices |
| **Deals** | 2 rows; blank Discount/UnitPrice is **by design** (uses DiscountPercentage instead) |
| **Buying Groups** | Full CRUD — Add modal opens, Edit pre-populates correctly |
| **Customer Categories** | Full CRUD, 8 rows |
| **Transaction Types** | Full CRUD, 10 rows |
| **Purchase Orders** | Master-detail, 10 rows each table |
| **Supplier Transactions** | 10 rows |
| **Suppliers** | Rich master-detail: 5 tables (suppliers + orders + lines + transactions + stock items) |
| **Supplier Categories** | Full CRUD, 9 rows |
| **Stock Items** | Edit/Delete per row, price data correct |
| **Stock Groups** | Full CRUD, 10 rows |
| **Colors** | Full CRUD, 10 rows |
| **Package Types** | Full CRUD — Bag, Box, Carton, Each, Pair… |
| **Countries** | Full CRUD, 10 rows, all columns populated |
| **Contact** | Static page renders |
| **Offers / Product Search** | Name filter works (20→filtered), category buttons toggle |
| **DataTables** | Search (instant filter), pagination (54 entries / 10 per page), server-side processing |

---

## 🐛 Bugs Found

### Bug 1 — State/Province column blank in Cities
**Severity:** Medium  
**Page:** `/Cities`

All rows show an empty State/Province column. The OData `/Cities` endpoint returns `StateProvinceID` (FK) but never expands `StateProvinceName`. The DataTable column expects the name but it is never returned by the server.

**Steps to reproduce:**
1. Navigate to Locations → Cities
2. Observe the State/Province column — blank for all rows

**Fix:** Backend `/Table/Cities` endpoint needs to join or `$expand` `StateProvince.StateProvinceName`.

---

### Bug 2 — Country column blank in StateProvinces
**Severity:** Medium  
**Page:** `/StateProvinces`

Same root cause as Bug 1 — OData returns `CountryID` only. Confirmed via direct OData query:  
`GET /OData/StateProvinces?$top=3&$select=StateProvinceName,CountryName` → `CountryName` field is absent in every response record.

**Steps to reproduce:**
1. Navigate to Locations → State Provinces
2. Observe the Country column — blank for all 54 rows (checked pages 1 and 2)

**Fix:** Backend `/Table/StateProvinces` must return `CountryName`, either via `$expand=Country($select=CountryName)` in the OData query or a server-side join.

---

### Bug 3 — Delete has no confirmation dialog
**Severity:** High (data safety)  
**Pages:** Buying Groups, Customer Categories, Transaction Types, Colors, Package Types, Stock Groups, StateProvinces, Cities, Countries

The delete button directly calls `o('...').find(id).remove().save()` with no confirmation step. One misclick permanently deletes a record with no undo.

**Steps to reproduce:**
1. Navigate to any CRUD page (e.g. Buying Groups)
2. Click the red Delete button next to any row
3. Record is immediately deleted — no confirmation asked

**Fix:** Add a confirmation modal or `window.confirm("Are you sure?")` before executing the delete API call.

---

### Bug 4 — Add/Edit form missing client-side required validation
**Severity:** Low  
**Pages:** All CRUD modals (Buying Groups, Customer Categories, Colors, etc.)

Name inputs in CRUD modals have no `required` attribute. An empty name can be submitted, relying entirely on server-side validation (if any exists).

**Example:** `<input name="BuyingGroupName" type="text">` — no `required`, no `minlength`.

**Fix:** Add `required` attribute to mandatory inputs in all CRUD modals.

---

### Bug 5 — Product "Size" field always blank
**Severity:** Low  
**Page:** `/Offers`

All 20+ products display `Size:` with no value. The OData data returns `"Size": null` for every product record.

**Fix:** Either populate size data in the database, or conditionally hide the Size label when the value is null/empty.

---

### Bug 6 — Dashboard title implies region filtering that doesn't exist
**Severity:** Low (UX)  
**Page:** `/Dashboard`

The "Daily sales" chart heading reads **"Daily sales in All region"** but there is no region selector on the page. The label is hardcoded; no filter control exists in `Dashboard.js`.

**Fix:** Either add a region filter dropdown linked to the chart query, or change the heading to "Daily sales (all regions)".

---

### Bug 7 — Category filters disappear after Offers search
**Severity:** Low (UX)  
**Page:** `/Offers`

After typing a product name and clicking "Refine search," the category filter button group no longer renders in the results view.

**Steps to reproduce:**
1. Navigate to Offers
2. Type "mug" in the Name field and click Refine search
3. Category filter buttons (Radio Control, Comfortable, etc.) disappear from the sidebar

**Fix:** Ensure category buttons are re-rendered or preserved after a search result is displayed.

---

## Auth / Session Note

Visiting `/Login` while already authenticated initiates a new OIDC flow and can reset the active session. Consider redirecting already-authenticated users from `/Login` directly to `/Dashboard`.

---

## Summary

| Severity | Count |
|---|---|
| High | 1 (no delete confirmation) |
| Medium | 2 (blank relational columns in Cities + StateProvinces) |
| Low | 4 (missing validation, blank Size, dashboard label, category filter UX) |
| **Total bugs** | **7** |

All 21 pages load and return data. Core CRUD flows (Add, Edit) work correctly. The main data integrity concern is the missing `$expand` on OData FK relationships for Cities and StateProvinces.
