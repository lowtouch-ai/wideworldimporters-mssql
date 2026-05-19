"""WebApi.SearchForStockItems → GET /stock-items/search"""

from typing import Any, Optional

from fastapi import Depends, Query
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from api.db import get_session
from api.routers.webapi import router


@router.get("/stock-items/search", status_code=200)
async def search_for_stock_items(
    name: Optional[str] = Query(None),
    tag: Optional[str] = Query(None),
    min_price: Optional[float] = Query(None, alias="minPrice"),
    max_price: Optional[float] = Query(None, alias="maxPrice"),
    stock_group_id: Optional[int] = Query(None, alias="stockGroupId"),
    maximum_rows_to_return: int = Query(100, alias="maximumRowsToReturn"),
    session: AsyncSession = Depends(get_session),
) -> dict[str, Any]:
    # TODO: verify JSON shape matches original FOR JSON PATH, WITHOUT_ARRAY_WRAPPER output
    async with session.begin():
        result = await session.execute(
            text(
                """
                WITH value AS (
                    SELECT si."StockItemID", si."StockItemName", si."Brand", si."ColorName",
                           si."UnitPrice", si."TaxRate", si."Size", si."MarketingComments",
                           si."CustomFields"
                    FROM webapi.stock_items AS si
                    WHERE (:name IS NULL OR si."StockItemName" ILIKE :name_pattern)
                    AND (:min_price IS NULL OR si."UnitPrice" > :min_price)
                    AND (:max_price IS NULL OR si."UnitPrice" < :max_price)
                )
                SELECT
                    (
                        SELECT json_agg(row_to_json(v))
                        FROM (
                            SELECT v."StockItemID", v."StockItemName", v."Brand", v."ColorName",
                                   v."UnitPrice", v."TaxRate", v."Size", v."MarketingComments"
                            FROM value v
                            WHERE (:tag IS NULL OR EXISTS (
                                SELECT 1
                                FROM jsonb_array_elements_text((v."CustomFields"::jsonb)->'Tags') AS t(tag)
                                WHERE t.tag = :tag
                            ))
                            AND (:stock_group_id IS NULL OR EXISTS (
                                SELECT 1 FROM warehouse.stockitemstockgroups sisg
                                WHERE sisg."StockItemID" = v."StockItemID"
                                AND sisg."StockGroupID" = :stock_group_id
                            ))
                            LIMIT :max_rows
                        ) v
                    ) AS value,
                    (
                        SELECT json_agg(row_to_json(tg))
                        FROM (
                            SELECT t.tag AS "Tag", COUNT(*) AS "Items"
                            FROM value v
                            CROSS JOIN LATERAL jsonb_array_elements_text((v."CustomFields"::jsonb)->'Tags') AS t(tag)
                            GROUP BY t.tag
                        ) tg
                    ) AS tags
                """
            ),
            {
                "name": name,
                "name_pattern": f"%{name}%" if name else None,
                "min_price": min_price,
                "max_price": max_price,
                "tag": tag,
                "stock_group_id": stock_group_id,
                "max_rows": maximum_rows_to_return,
            },
        )
        row = result.mappings().first()
    return dict(row) if row else {"value": None, "tags": None}
