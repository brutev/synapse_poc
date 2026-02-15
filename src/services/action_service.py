import re
from typing import Any

from fastapi import HTTPException, status

from src.repositories.application_repository import ApplicationRepository
from src.repositories.application_section_data_repository import ApplicationSectionDataRepository
from src.schemas.action import ActionRequest, ActionResponse


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
        application = await self.app_repository.get_by_id(request.applicationId)
        if application is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Application not found",
            )

        if request.actionId != self._VERIFY_PAN:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Unsupported actionId",
            )

        result = self._mock_verify_pan(request.payload)

        try:
            await self.section_data_repository.merge_fields(
                application_id=application.id,
                section_id=self._KYC_SECTION_ID,
                updated_fields=result["updatedFields"],
            )
            await self.section_data_repository.commit()
        except Exception as exc:  # pragma: no cover
            await self.section_data_repository.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to persist action result",
            ) from exc

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
