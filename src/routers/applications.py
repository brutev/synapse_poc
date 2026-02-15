from fastapi import APIRouter, Depends, status

from src.schemas.application import CreateApplicationResponse
from src.services.application_service import ApplicationService
from src.services.dependencies import get_application_service

router = APIRouter(prefix="/applications", tags=["applications"])


@router.post("", response_model=CreateApplicationResponse, status_code=status.HTTP_201_CREATED)
async def create_application(
    service: ApplicationService = Depends(get_application_service),
) -> CreateApplicationResponse:
    return await service.create_application()
