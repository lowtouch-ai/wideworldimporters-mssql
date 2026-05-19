"""WebApi.DeleteCustomer → DELETE /customers/{customer_id}"""

from fastapi import Depends, HTTPException
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from api.db import get_session
from api.routers.webapi import router


@router.delete("/customers/{customer_id}", status_code=204)
async def delete_customer(
    customer_id: int,
    session: AsyncSession = Depends(get_session),
) -> None:
    async with session.begin():
        result = await session.execute(
            text('DELETE FROM sales.customers WHERE "CustomerID" = :id'),
            {"id": customer_id},
        )
    if result.rowcount == 0:
        raise HTTPException(status_code=404, detail="Customer not found")
