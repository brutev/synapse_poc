import logging
from fastapi import HTTPException, status

from src.repositories.application_repository import ApplicationRepository
from src.schemas.evaluate import EvaluateRequest, EvaluateResponse
from src.services.rule_service import RuleService

logger = logging.getLogger(__name__)


class EvaluateService:
    def __init__(self, app_repository: ApplicationRepository, rule_service: RuleService) -> None:
        self.app_repository = app_repository
        self.rule_service = rule_service

    async def evaluate(self, request: EvaluateRequest) -> EvaluateResponse:
        try:
            logger.info("Evaluate request for applicationId=%s, phase=%s", 
                       request.applicationId, request.phase)
            
            application = await self.app_repository.get_by_id(request.applicationId)
            if application is None:
                logger.error("Application not found: %s", request.applicationId)
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Application not found",
                )

            if request.phase != application.phase:
                logger.error("Phase mismatch: expected %s, got %s", 
                           application.phase, request.phase)
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="Phase mismatch for application",
                )

            result = await self.rule_service.evaluate(
                application_id=application.id,
                rule_version=application.rule_version,
                phase=application.phase,
                request_section_data=request.sectionData,
            )
            logger.info("Evaluate successful for applicationId=%s", request.applicationId)
            return result
        except HTTPException:
            raise
        except Exception as exc:
            logger.error("Evaluate error: %s", str(exc), exc_info=True)
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Evaluate failed: {str(exc)}",
            ) from exc
