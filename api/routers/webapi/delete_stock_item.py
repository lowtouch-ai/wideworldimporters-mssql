"""WebApi.DeleteStockItem → DELETE /stock-items/{stock_item_id}"""

from fastapi import Depends, HTTPException
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from api.db import get_session
from api.routers.webapi import router


@router.delete("/stock-items/{stock_item_id}", status_code=204)
async def delete_stock_item(
    stock_item_id: int,
    session: AsyncSession = Depends(get_session),
) -> None:
    async with session.begin():
        result = await session.execute(
            text('DELETE FROM warehouse.stockitems WHERE "StockItemID" = :id'),
            {"id": stock_item_id},
        )
    if result.rowcount == 0:
        raise HTTPException(status_code=404, detail="StockItem not found")
