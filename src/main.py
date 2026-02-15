from fastapi import FastAPI

from src.core.config import get_settings
from src.routers.action import router as action_router
from src.routers.applications import router as applications_router
from src.routers.evaluate import router as evaluate_router
from src.routers.save_draft import router as save_draft_router
from src.routers.submit import router as submit_router

settings = get_settings()

app = FastAPI(title=settings.app_name)

app.include_router(applications_router)
app.include_router(evaluate_router)
app.include_router(action_router)
app.include_router(save_draft_router)
app.include_router(submit_router)
