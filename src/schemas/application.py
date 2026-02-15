from uuid import UUID

from pydantic import BaseModel


class CreateApplicationResponse(BaseModel):
    applicationId: UUID
    ruleVersion: str
