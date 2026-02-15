from fastapi import HTTPException, status

from src.repositories.application_repository import ApplicationRepository
from src.schemas.evaluate import EvaluateRequest, EvaluateResponse
from src.services.rule_service import RuleService


class EvaluateService:
    def __init__(self, app_repository: ApplicationRepository, rule_service: RuleService) -> None:
        self.app_repository = app_repository
        self.rule_service = rule_service

    async def evaluate(self, request: EvaluateRequest) -> EvaluateResponse:
        application = await self.app_repository.get_by_id(request.applicationId)
        if application is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Application not found",
            )

        if request.phase != application.phase:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Phase mismatch for application",
            )

        return await self.rule_service.evaluate(
            application_id=application.id,
            rule_version=application.rule_version,
            phase=application.phase,
            request_section_data=request.sectionData,
        )
