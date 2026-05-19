"""WebApi.DeleteColor → DELETE /colors/{color_id}"""

from fastapi import Depends, HTTPException
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from api.db import get_session
from api.routers.webapi import router


@router.delete("/colors/{color_id}", status_code=204)
async def delete_color(
    color_id: int,
    session: AsyncSession = Depends(get_session),
) -> None:
    async with session.begin():
        result = await session.execute(
            text('DELETE FROM warehouse.colors WHERE "ColorID" = :id'),
            {"id": color_id},
        )
    if result.rowcount == 0:
        raise HTTPException(status_code=404, detail="Color not found")
