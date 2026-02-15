from fastapi import APIRouter, Depends

from src.schemas.evaluate import EvaluateRequest, EvaluateResponse
from src.services.dependencies import get_evaluate_service
from src.services.evaluate_service import EvaluateService

router = APIRouter(tags=["evaluate"])


@router.post("/evaluate", response_model=EvaluateResponse)
async def evaluate(
    request: EvaluateRequest,
    service: EvaluateService = Depends(get_evaluate_service),
) -> EvaluateResponse:
    return await service.evaluate(request)
