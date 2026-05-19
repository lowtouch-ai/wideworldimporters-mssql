"""WebApi.DeletePaymentMethod → DELETE /payment-methods/{payment_method_id}"""

from fastapi import Depends, HTTPException
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from api.db import get_session
from api.routers.webapi import router


@router.delete("/payment-methods/{payment_method_id}", status_code=204)
async def delete_payment_method(
    payment_method_id: int,
    session: AsyncSession = Depends(get_session),
) -> None:
    async with session.begin():
        result = await session.execute(
            text('DELETE FROM application.payment_methods WHERE "PaymentMethodID" = :id'),
            {"id": payment_method_id},
        )
    if result.rowcount == 0:
        raise HTTPException(status_code=404, detail="PaymentMethod not found")
