import logging
from fastapi import HTTPException, status

from src.models.application import Application
from src.repositories.application_repository import ApplicationRepository
from src.schemas.application import CreateApplicationResponse

logger = logging.getLogger(__name__)


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
            logger.info("Creating application with rule_version=%s, phase=%s", 
                       self.DEFAULT_RULE_VERSION, self.DEFAULT_PHASE)
            created = await self.repository.create(application)
            await self.repository.commit()
            logger.info("Application created successfully: %s", created.id)
        except Exception as exc:  # pragma: no cover
            logger.error("Error creating application: %s", str(exc), exc_info=True)
            await self.repository.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to create application: {str(exc)}",
            ) from exc

        return CreateApplicationResponse(
            applicationId=created.id,
            ruleVersion=created.rule_version,
        )
