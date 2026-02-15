from typing import Any
from uuid import UUID

from pydantic import BaseModel, ConfigDict


class ActionRequest(BaseModel):
    applicationId: UUID
    actionId: str
    payload: dict[str, Any]

    model_config = ConfigDict(extra="forbid")


class ActionResponse(BaseModel):
    success: bool
    updatedFields: dict[str, Any]
    fieldLocks: list[str]
    message: str

    model_config = ConfigDict(extra="forbid")
