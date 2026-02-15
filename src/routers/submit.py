from fastapi import APIRouter, Depends

from src.schemas.submit import SubmitRequest, SubmitResponse
from src.services.dependencies import get_submit_service
from src.services.submit_service import SubmitService

router = APIRouter(tags=["submit"])


@router.post("/submit", response_model=SubmitResponse)
async def submit(
    request: SubmitRequest,
    service: SubmitService = Depends(get_submit_service),
) -> SubmitResponse:
    return await service.submit(request)
