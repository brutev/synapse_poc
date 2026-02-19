import logging
import re
from typing import Any

from fastapi import HTTPException, status

from src.repositories.application_repository import ApplicationRepository
from src.repositories.application_section_data_repository import ApplicationSectionDataRepository
from src.schemas.action import ActionRequest, ActionResponse

logger = logging.getLogger(__name__)


class ActionService:
    _VERIFY_PAN = "VERIFY_PAN"
    _PAN_PATTERN = re.compile(r"^[A-Z]{5}[0-9]{4}[A-Z]$")
    _KYC_SECTION_ID = "KYC"

    def __init__(
        self,
        app_repository: ApplicationRepository,
        section_data_repository: ApplicationSectionDataRepository,
    ) -> None:
        self.app_repository = app_repository
        self.section_data_repository = section_data_repository

    async def execute(self, request: ActionRequest) -> ActionResponse:
        logger.info(f"[ACTION] Executing action {request.actionId} for app {request.applicationId}")
        
        application = await self.app_repository.get_by_id(request.applicationId)
        if application is None:
            logger.error(f"[ACTION] Application not found: {request.applicationId}")
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Application not found",
            )

        if request.actionId != self._VERIFY_PAN:
            logger.error(f"[ACTION] Unsupported actionId: {request.actionId}")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Unsupported actionId",
            )

        result = self._mock_verify_pan(request.payload)
        logger.info(f"[ACTION] Mock verification result: {result}")

        try:
            logger.info(
                f"[ACTION] Merging fields for app={request.applicationId}, section={self._KYC_SECTION_ID}"
            )
            await self.section_data_repository.merge_fields(
                application_id=request.applicationId,
                section_id=self._KYC_SECTION_ID,
                updated_fields=result["updatedFields"],
            )
            logger.info("[ACTION] Fields merged, committing transaction")
            await self.section_data_repository.commit()
            logger.info("[ACTION] Transaction committed successfully")
        except Exception as exc:
            logger.error(f"[ACTION] Failed to persist action result: {exc}", exc_info=True)
            await self.section_data_repository.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to persist action result: {str(exc)}",
            ) from exc

        logger.info(f"[ACTION] Action {request.actionId} completed successfully")
        return ActionResponse(
            success=result["success"],
            updatedFields=result["updatedFields"],
            fieldLocks=result["fieldLocks"],
            message=result["message"],
        )

    def _mock_verify_pan(self, payload: dict[str, Any]) -> dict[str, Any]:
        pan_number = str(payload.get("panNumber", "")).upper().strip()
        if not pan_number:
            return {
                "success": False,
                "updatedFields": {"panVerified": False},
                "fieldLocks": [],
                "message": "PAN number missing in payload",
            }

        is_valid = bool(self._PAN_PATTERN.fullmatch(pan_number))
        if not is_valid:
            return {
                "success": False,
                "updatedFields": {"panVerified": False},
                "fieldLocks": [],
                "message": "PAN format invalid",
            }

        return {
            "success": True,
            "updatedFields": {
                "panVerified": True,
                "panHolderName": "VERIFIED USER",
            },
            "fieldLocks": ["panNumber", "panVerified"],
            "message": "PAN verified successfully",
        }
