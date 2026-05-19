from fastapi import FastAPI

app = FastAPI(title="WideWorldImporters API")

from api.routers.webapi import router as webapi_router  # noqa: E402
app.include_router(webapi_router)
