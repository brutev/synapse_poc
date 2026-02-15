from datetime import datetime
from typing import Any
from uuid import UUID

from pydantic import BaseModel, ConfigDict


class SaveDraftRequest(BaseModel):
    applicationId: UUID
    sectionId: str
    data: dict[str, Any]

    model_config = ConfigDict(extra="forbid")


class SaveDraftResponse(BaseModel):
    success: bool
    timestamp: datetime

    model_config = ConfigDict(extra="forbid")
