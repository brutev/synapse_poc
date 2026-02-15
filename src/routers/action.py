from fastapi import APIRouter, Depends

from src.schemas.action import ActionRequest, ActionResponse
from src.services.action_service import ActionService
from src.services.dependencies import get_action_service

router = APIRouter(tags=["action"])


@router.post("/action", response_model=ActionResponse)
async def action(
    request: ActionRequest,
    service: ActionService = Depends(get_action_service),
) -> ActionResponse:
    return await service.execute(request)
