# Conversion summary: WebApi.UpdateInvoiceFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateInvoiceFromJson.sql`
- **Pattern:** Update from JSON (partial update)
- **Output:** `postgres/WebApi/Functions/update_invoice_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.update_invoice_from_json(p_invoice text, p_invoice_id integer, p_user_id integer) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@Invoice nvarchar(MAX)` | `p_invoice text` | text | JSON object payload (15 fields) |
| `@InvoiceID int` | `p_invoice_id integer` | integer | PK to update |
| `@UserID int` | `p_user_id integer` | integer | Audit user |

## Conversion notes
- `COALESCE` for: CustomerID, BillToCustomerID, DeliveryMethodID, ContactPersonID, AccountsPersonID, SalespersonPersonID, PackedByPersonID, InvoiceDate, IsCreditNote, TotalDryItems, TotalChillerItems
- Direct for: CustomerPurchaseOrderNumber, DeliveryRun, RunPosition (all nullable)
- OrderID in OPENJSON WITH clause but not used in SET — kept in AS clause for completeness, not referenced in SET

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.invoices` | `postgres/Sales/Tables/Invoices.sql` |
