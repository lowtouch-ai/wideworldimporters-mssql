"""WebApi.DeleteCity → DELETE /cities/{city_id}"""

from fastapi import Depends, HTTPException
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from api.db import get_session
from api.routers.webapi import router


@router.delete("/cities/{city_id}", status_code=204)
async def delete_city(
    city_id: int,
    session: AsyncSession = Depends(get_session),
) -> None:
    async with session.begin():
        result = await session.execute(
            text('DELETE FROM application.cities WHERE "CityID" = :id'),
            {"id": city_id},
        )
    if result.rowcount == 0:
        raise HTTPException(status_code=404, detail="City not found")
