# Conversion summary: WebApi.DeleteBuyingGroup

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteBuyingGroup.sql`
- **Pattern:** Simple DELETE
- **HTTP:** DELETE `/web-api/buying-groups/{buying_group_id}` → 204 No Content / 404

## Tables/views referenced
| Object | Postgres file | Status |
|---|---|---|
| `sales.buying_groups` | `postgres/Sales/Tables/BuyingGroups.sql` | Converted |

## Parameter mapping
| SP Parameter | Endpoint parameter | Type | Notes |
|---|---|---|---|
| `@BuyingGroupID int` | Path param `buying_group_id: int` | int | Primary key |

## SQL construct conversions
- `DELETE FROM [Sales].[BuyingGroups] WHERE BuyingGroupID = @BuyingGroupID` → `text("DELETE FROM sales.buying_groups WHERE \"BuyingGroupID\" = :id")`
- `@@ROWCOUNT = 0` → `result.rowcount == 0` → `HTTPException(404)`
