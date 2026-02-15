from fastapi import APIRouter, Depends

from src.schemas.save_draft import SaveDraftRequest, SaveDraftResponse
from src.services.dependencies import get_save_draft_service
from src.services.save_draft_service import SaveDraftService

router = APIRouter(tags=["save-draft"])


@router.post("/save-draft", response_model=SaveDraftResponse)
async def save_draft(
    request: SaveDraftRequest,
    service: SaveDraftService = Depends(get_save_draft_service),
) -> SaveDraftResponse:
    return await service.save(request)
