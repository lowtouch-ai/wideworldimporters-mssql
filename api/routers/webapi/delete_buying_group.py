"""WebApi.DeleteBuyingGroup → DELETE /buying-groups/{buying_group_id}"""

from fastapi import Depends, HTTPException
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from api.db import get_session
from api.routers.webapi import router


@router.delete("/buying-groups/{buying_group_id}", status_code=204)
async def delete_buying_group(
    buying_group_id: int,
    session: AsyncSession = Depends(get_session),
) -> None:
    async with session.begin():
        result = await session.execute(
            text('DELETE FROM sales.buying_groups WHERE "BuyingGroupID" = :id'),
            {"id": buying_group_id},
        )
    if result.rowcount == 0:
        raise HTTPException(status_code=404, detail="BuyingGroup not found")
