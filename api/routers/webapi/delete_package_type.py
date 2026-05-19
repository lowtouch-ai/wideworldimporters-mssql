"""WebApi.DeletePackageType → DELETE /package-types/{package_type_id}"""

from fastapi import Depends, HTTPException
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from api.db import get_session
from api.routers.webapi import router


@router.delete("/package-types/{package_type_id}", status_code=204)
async def delete_package_type(
    package_type_id: int,
    session: AsyncSession = Depends(get_session),
) -> None:
    async with session.begin():
        result = await session.execute(
            text('DELETE FROM warehouse.package_types WHERE "PackageTypeID" = :id'),
            {"id": package_type_id},
        )
    if result.rowcount == 0:
        raise HTTPException(status_code=404, detail="PackageType not found")
