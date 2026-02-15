from fastapi import HTTPException, status

from src.repositories.application_repository import ApplicationRepository
from src.schemas.submit import SubmitRequest, SubmitResponse
from src.services.rule_service import RuleService


class SubmitService:
    def __init__(self, app_repository: ApplicationRepository, rule_service: RuleService) -> None:
        self.app_repository = app_repository
        self.rule_service = rule_service

    async def submit(self, request: SubmitRequest) -> SubmitResponse:
        application = await self.app_repository.get_by_id(request.applicationId)
        if application is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Application not found",
            )

        evaluation = await self.rule_service.evaluate(
            application_id=application.id,
            rule_version=application.rule_version,
            phase=application.phase,
            request_section_data={},
        )

        mandatory_sections = [
            section
            for section in evaluation.sections
            if section.mandatory and section.visible
        ]
        missing_mandatory_sections = [
            section.sectionId
            for section in mandatory_sections
            if section.status != "COMPLETED"
        ]

        if missing_mandatory_sections:
            return SubmitResponse(
                success=False,
                missingMandatorySections=missing_mandatory_sections,
            )

        return SubmitResponse(success=True, nextPhase="POST_SANCTION")
