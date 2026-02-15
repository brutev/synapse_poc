from uuid import UUID

from pydantic import BaseModel, ConfigDict


class SubmitRequest(BaseModel):
    applicationId: UUID

    model_config = ConfigDict(extra="forbid")


class SubmitResponse(BaseModel):
    success: bool
    nextPhase: str | None = None
    missingMandatorySections: list[str] | None = None

    model_config = ConfigDict(extra="forbid")
