from __future__ import annotations

from copy import deepcopy
from typing import Any
from uuid import UUID

from fastapi import HTTPException, status

from src.repositories.application_override_repository import ApplicationOverrideRepository
from src.repositories.application_section_data_repository import ApplicationSectionDataRepository
from src.schemas.evaluate import Action, EvaluateResponse, Field, Section


class RuleService:
    _ALLOWED_OVERRIDE_FLAGS = {"mandatory", "editable", "visible"}
    _SUPPORTED_RULE_VERSION = "1.0.0"

    _BASE_RULE_CONFIG: dict[str, Any] = {
        "sections": [
            {
                "sectionId": "PERSONAL_INFO",
                "mandatory": True,
                "editable": True,
                "visible": True,
                "fields": [
                    {
                        "fieldId": "fullName",
                        "type": "string",
                        "mandatory": True,
                        "editable": True,
                        "visible": True,
                        "validation": {"minLength": 2},
                    },
                    {
                        "fieldId": "dateOfBirth",
                        "type": "date",
                        "mandatory": True,
                        "editable": True,
                        "visible": True,
                        "validation": {},
                    },
                    {
                        "fieldId": "panNumber",
                        "type": "string",
                        "mandatory": True,
                        "editable": True,
                        "visible": True,
                        "validation": {"pattern": "^[A-Z]{5}[0-9]{4}[A-Z]$"},
                    },
                ],
            },
            {
                "sectionId": "KYC",
                "mandatory": True,
                "editable": True,
                "visible": True,
                "fields": [
                    {
                        "fieldId": "panVerified",
                        "type": "boolean",
                        "mandatory": True,
                        "editable": False,
                        "visible": True,
                        "validation": {},
                    },
                    {
                        "fieldId": "panHolderName",
                        "type": "string",
                        "mandatory": False,
                        "editable": False,
                        "visible": True,
                        "validation": {},
                    },
                ],
            },
            {
                "sectionId": "EMPLOYMENT",
                "mandatory": False,
                "editable": True,
                "visible": True,
                "fields": [
                    {
                        "fieldId": "employmentType",
                        "type": "string",
                        "mandatory": False,
                        "editable": True,
                        "visible": True,
                        "validation": {},
                    },
                    {
                        "fieldId": "monthlyIncome",
                        "type": "number",
                        "mandatory": False,
                        "editable": True,
                        "visible": True,
                        "validation": {"min": 0},
                    },
                ],
            },
        ],
        "actions": [
            {
                "actionId": "VERIFY_PAN",
                "triggerField": "panNumber",
            },
        ],
    }

    def __init__(
        self,
        section_data_repository: ApplicationSectionDataRepository,
        override_repository: ApplicationOverrideRepository,
    ) -> None:
        self.section_data_repository = section_data_repository
        self.override_repository = override_repository

    async def evaluate(
        self,
        application_id: UUID,
        rule_version: str,
        phase: str,
        request_section_data: dict[str, Any] | None,
    ) -> EvaluateResponse:
        if rule_version != self._SUPPORTED_RULE_VERSION:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Unsupported rule version",
            )

        config = deepcopy(self._BASE_RULE_CONFIG)

        override = await self.override_repository.get_by_application_id(application_id)
        if override is not None:
            self._apply_overrides(config, override.override_patch)

        persisted_section_data = await self.section_data_repository.get_by_application_id(application_id)
        persisted_map = {item.section_id: item.data for item in persisted_section_data}
        request_map = self._normalize_section_input(request_section_data)
        merged_map = dict(persisted_map)
        for section_id, section_payload in request_map.items():
            current = merged_map.get(section_id, {})
            if isinstance(current, dict):
                merged = dict(current)
                merged.update(section_payload)
                merged_map[section_id] = merged
            else:
                merged_map[section_id] = section_payload

        sections = [
            self._materialize_section(section_config, merged_map.get(section_config["sectionId"], {}))
            for section_config in config["sections"]
        ]
        actions = [Action(**action_config) for action_config in config["actions"]]

        return EvaluateResponse(
            ruleVersion=rule_version,
            applicationId=application_id,
            phase=phase,
            sections=sections,
            actions=actions,
        )

    def _apply_overrides(self, config: dict[str, Any], override_patch: dict[str, Any]) -> None:
        section_overrides = override_patch.get("sections", override_patch)
        if not isinstance(section_overrides, dict):
            return

        sections_by_id = {section["sectionId"]: section for section in config["sections"]}

        for section_id, patch in section_overrides.items():
            section = sections_by_id.get(section_id)
            if section is None or not isinstance(patch, dict):
                continue

            self._apply_flag_patch(section, patch)

            field_overrides = patch.get("fields")
            if not isinstance(field_overrides, dict):
                continue

            fields_by_id = {field["fieldId"]: field for field in section["fields"]}
            for field_id, field_patch in field_overrides.items():
                field = fields_by_id.get(field_id)
                if field is None or not isinstance(field_patch, dict):
                    continue
                self._apply_flag_patch(field, field_patch)

    def _apply_flag_patch(self, target: dict[str, Any], patch: dict[str, Any]) -> None:
        for flag in self._ALLOWED_OVERRIDE_FLAGS:
            value = patch.get(flag)
            if isinstance(value, bool):
                target[flag] = value

    def _materialize_section(self, section_config: dict[str, Any], section_data: dict[str, Any]) -> Section:
        fields: list[Field] = []
        normalized_section_data = section_data if isinstance(section_data, dict) else {}

        for field_config in section_config["fields"]:
            field_id = field_config["fieldId"]
            value = normalized_section_data.get(field_id)
            field = Field(
                fieldId=field_id,
                type=field_config["type"],
                value=value,
                mandatory=field_config["mandatory"],
                editable=field_config["editable"],
                visible=field_config["visible"],
                validation=field_config["validation"],
            )
            fields.append(field)

        status = self._derive_section_status(
            section_visible=section_config["visible"],
            fields=fields,
        )

        return Section(
            sectionId=section_config["sectionId"],
            mandatory=section_config["mandatory"],
            editable=section_config["editable"],
            visible=section_config["visible"],
            status=status,
            fields=fields,
        )

    def _derive_section_status(self, section_visible: bool, fields: list[Field]) -> str:
        if not section_visible:
            return "HIDDEN"

        mandatory_fields = [field for field in fields if field.mandatory and field.visible]
        if not mandatory_fields:
            return "COMPLETED"

        mandatory_values = [self._has_value(field.value) for field in mandatory_fields]
        all_mandatory_completed = all(mandatory_values)
        if all_mandatory_completed:
            return "COMPLETED"

        any_value_present = any(self._has_value(field.value) for field in fields)
        return "IN_PROGRESS" if any_value_present else "PENDING"

    def _normalize_section_input(self, section_data: dict[str, Any] | None) -> dict[str, dict[str, Any]]:
        if section_data is None:
            return {}

        normalized: dict[str, dict[str, Any]] = {}
        for section_id, payload in section_data.items():
            if isinstance(payload, dict):
                normalized[section_id] = payload
        return normalized

    def _has_value(self, value: Any) -> bool:
        if value is None:
            return False
        if isinstance(value, str):
            return value.strip() != ""
        return True
