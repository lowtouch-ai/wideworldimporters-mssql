"""WebApi.Login → POST /login"""

from typing import Any

from fastapi import Depends, HTTPException, Query
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from api.db import get_session
from api.routers.webapi import router


@router.post("/login", status_code=200)
async def login(
    logon_name: str = Query(..., alias="logonName"),
    password: str = Query(...),  # TODO: replace with auth dependency; password not currently validated by SP
    session: AsyncSession = Depends(get_session),
) -> dict[str, Any]:
    async with session.begin():
        result = await session.execute(
            text(
                'SELECT "PersonID", "PreferredName", "IsSalesperson", "IsEmployee",'
                ' ("CustomFields"::jsonb)->>\'PrimarySalesTerritory\' AS "Territory"'
                ' FROM application.people'
                ' WHERE "IsPermittedToLogon" = TRUE AND "LogonName" = :logon_name'
            ),
            {"logon_name": logon_name},
        )
        row = result.mappings().first()
    if row is None:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    return dict(row)
