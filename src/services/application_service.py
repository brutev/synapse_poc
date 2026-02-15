from fastapi import HTTPException, status

from src.models.application import Application
from src.repositories.application_repository import ApplicationRepository
from src.schemas.application import CreateApplicationResponse


class ApplicationService:
    DEFAULT_RULE_VERSION = "1.0.0"
    DEFAULT_PHASE = "PRE_SANCTION"

    def __init__(self, repository: ApplicationRepository) -> None:
        self.repository = repository

    async def create_application(self) -> CreateApplicationResponse:
        application = Application(
            rule_version=self.DEFAULT_RULE_VERSION,
            phase=self.DEFAULT_PHASE,
        )

        try:
            created = await self.repository.create(application)
            await self.repository.commit()
        except Exception as exc:  # pragma: no cover
            await self.repository.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to create application",
            ) from exc

        return CreateApplicationResponse(
            applicationId=created.id,
            ruleVersion=created.rule_version,
        )
