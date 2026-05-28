# customers (view)

Converted from: `wwi-ssdt/wwi-ssdt/Website/Views/Customers.sql`

## Summary

Denormalized view of customers joining categories, contacts, buying groups, delivery methods, and cities.

## Conversion notes

- `CREATE VIEW [Website].[Customers]` → `CREATE OR REPLACE VIEW website.customers`
- `LEFT OUTER JOIN` → `LEFT JOIN`
- `GO` removed
- All schema/table references lowercased

## Dependencies

| Object | Status |
|---|---|
| `sales.customers` | check postgres/Sales/Tables/Customers.sql |
| `sales.customercategories` | check postgres/Sales/Tables/CustomerCategories.sql |
| `sales.buyinggroups` | check postgres/Sales/Tables/BuyingGroups.sql |
| `application.people` | check postgres/Application/Tables/People.sql |
| `application.deliverymethods` | check postgres/Application/Tables/DeliveryMethods.sql |
| `application.cities` | check postgres/Application/Tables/Cities.sql |
