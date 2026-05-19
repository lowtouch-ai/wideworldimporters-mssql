# Conversion summary: WebApi.PaymentMethods

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/WebApi/Views/PaymentMethods.sql`
- **Output:** `postgres/WebApi/Views/payment_methods.sql`

## Conversions applied
- `[WebApi].[PaymentMethods]` → `webapi.payment_methods`
- `[Application].PaymentMethods` → `application.payment_methods`

## Table dependencies
| Table | Postgres file | Status |
|---|---|---|
| `application.payment_methods` | `postgres/Application/Tables/PaymentMethods.sql` | ✓ converted |
