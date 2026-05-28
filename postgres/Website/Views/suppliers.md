# suppliers (view)

Converted from: `wwi-ssdt/wwi-ssdt/Website/Views/Suppliers.sql`

## Summary

Denormalized view of suppliers joining categories, contacts, delivery methods, and cities.

## Conversion notes

- `CREATE VIEW [Website].[Suppliers]` → `CREATE OR REPLACE VIEW website.suppliers`
- `LEFT OUTER JOIN` → `LEFT JOIN`
- `GO` removed
- All schema/table references lowercased

## Dependencies

| Object | Status |
|---|---|
| `purchasing.suppliers` | check postgres/Purchasing/Tables/Suppliers.sql |
| `purchasing.suppliercategories` | check postgres/Purchasing/Tables/SupplierCategories.sql |
| `application.people` | check postgres/Application/Tables/People.sql |
| `application.deliverymethods` | check postgres/Application/Tables/DeliveryMethods.sql |
| `application.cities` | check postgres/Application/Tables/Cities.sql |
