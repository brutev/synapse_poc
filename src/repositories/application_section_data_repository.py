from datetime import datetime, timezone
from typing import Any
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.models.application_section_data import ApplicationSectionData


class ApplicationSectionDataRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def get_by_application_id(self, application_id: UUID) -> list[ApplicationSectionData]:
        query = select(ApplicationSectionData).where(
            ApplicationSectionData.application_id == application_id,
        )
        result = await self.session.execute(query)
        return list(result.scalars().all())

    async def get_by_application_and_section(
        self,
        application_id: UUID,
        section_id: str,
    ) -> ApplicationSectionData | None:
        query = select(ApplicationSectionData).where(
            ApplicationSectionData.application_id == application_id,
            ApplicationSectionData.section_id == section_id,
        )
        result = await self.session.execute(query)
        return result.scalar_one_or_none()

    async def upsert(
        self,
        application_id: UUID,
        section_id: str,
        data: dict[str, Any],
    ) -> ApplicationSectionData:
        existing = await self.get_by_application_and_section(application_id, section_id)
        if existing is None:
            entity = ApplicationSectionData(
                application_id=application_id,
                section_id=section_id,
                data=data,
            )
            self.session.add(entity)
        else:
            existing.data = data
            entity = existing

        await self.session.flush()
        await self.session.refresh(entity)
        return entity

    async def merge_fields(
        self,
        application_id: UUID,
        section_id: str,
        updated_fields: dict[str, Any],
    ) -> ApplicationSectionData:
        existing = await self.get_by_application_and_section(application_id, section_id)
        if existing is None:
            entity = ApplicationSectionData(
                application_id=application_id,
                section_id=section_id,
                data=updated_fields,
            )
            self.session.add(entity)
        else:
            merged = dict(existing.data)
            merged.update(updated_fields)
            existing.data = merged
            entity = existing

        await self.session.flush()
        await self.session.refresh(entity)
        return entity

    async def commit(self) -> None:
        await self.session.commit()

    async def rollback(self) -> None:
        await self.session.rollback()

    @staticmethod
    def now_utc() -> datetime:
        return datetime.now(timezone.utc)
