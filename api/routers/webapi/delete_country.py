"""WebApi.DeleteCountry → DELETE /countries/{country_id}"""

from fastapi import Depends, HTTPException
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from api.db import get_session
from api.routers.webapi import router


@router.delete("/countries/{country_id}", status_code=204)
async def delete_country(
    country_id: int,
    session: AsyncSession = Depends(get_session),
) -> None:
    async with session.begin():
        result = await session.execute(
            text('DELETE FROM application.countries WHERE "CountryID" = :id'),
            {"id": country_id},
        )
    if result.rowcount == 0:
        raise HTTPException(status_code=404, detail="Country not found")
