"""WebApi.DeleteCustomerCategory → DELETE /customer-categories/{customer_category_id}"""

from fastapi import Depends, HTTPException
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from api.db import get_session
from api.routers.webapi import router


@router.delete("/customer-categories/{customer_category_id}", status_code=204)
async def delete_customer_category(
    customer_category_id: int,
    session: AsyncSession = Depends(get_session),
) -> None:
    async with session.begin():
        result = await session.execute(
            text('DELETE FROM sales.customer_categories WHERE "CustomerCategoryID" = :id'),
            {"id": customer_category_id},
        )
    if result.rowcount == 0:
        raise HTTPException(status_code=404, detail="CustomerCategory not found")
