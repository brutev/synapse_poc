from fastapi import HTTPException, status

from src.repositories.application_repository import ApplicationRepository
from src.repositories.application_section_data_repository import ApplicationSectionDataRepository
from src.schemas.save_draft import SaveDraftRequest, SaveDraftResponse


class SaveDraftService:
    def __init__(
        self,
        app_repository: ApplicationRepository,
        section_data_repository: ApplicationSectionDataRepository,
    ) -> None:
        self.app_repository = app_repository
        self.section_data_repository = section_data_repository

    async def save(self, request: SaveDraftRequest) -> SaveDraftResponse:
        application = await self.app_repository.get_by_id(request.applicationId)
        if application is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Application not found",
            )

        try:
            await self.section_data_repository.upsert(
                application_id=application.id,
                section_id=request.sectionId,
                data=request.data,
            )
            await self.section_data_repository.commit()
        except Exception as exc:  # pragma: no cover
            await self.section_data_repository.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to save draft",
            ) from exc

        return SaveDraftResponse(
            success=True,
            timestamp=self.section_data_repository.now_utc(),
        )
