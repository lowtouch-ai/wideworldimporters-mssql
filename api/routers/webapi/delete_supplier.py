"""WebApi.DeleteSupplier → DELETE /suppliers/{supplier_id}"""

from fastapi import Depends, HTTPException
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from api.db import get_session
from api.routers.webapi import router


@router.delete("/suppliers/{supplier_id}", status_code=204)
async def delete_supplier(
    supplier_id: int,
    session: AsyncSession = Depends(get_session),
) -> None:
    async with session.begin():
        result = await session.execute(
            text('DELETE FROM purchasing.suppliers WHERE "SupplierID" = :id'),
            {"id": supplier_id},
        )
    if result.rowcount == 0:
        raise HTTPException(status_code=404, detail="Supplier not found")
