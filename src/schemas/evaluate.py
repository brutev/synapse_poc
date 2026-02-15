from typing import Any
from uuid import UUID

from pydantic import BaseModel, ConfigDict


class EvaluateRequest(BaseModel):
    applicationId: UUID
    phase: str
    context: dict[str, Any]
    sectionData: dict[str, Any]

    model_config = ConfigDict(extra="forbid")


class Field(BaseModel):
    fieldId: str
    type: str
    value: Any | None = None
    mandatory: bool
    editable: bool
    visible: bool
    validation: dict[str, Any]

    model_config = ConfigDict(extra="forbid")


class Section(BaseModel):
    sectionId: str
    mandatory: bool
    editable: bool
    visible: bool
    status: str
    fields: list[Field]

    model_config = ConfigDict(extra="forbid")


class Action(BaseModel):
    actionId: str
    triggerField: str

    model_config = ConfigDict(extra="forbid")


class EvaluateResponse(BaseModel):
    ruleVersion: str
    applicationId: UUID
    phase: str
    sections: list[Section]
    actions: list[Action]

    model_config = ConfigDict(extra="forbid")
