from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.models.application_override import ApplicationOverride


class ApplicationOverrideRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def get_by_application_id(self, application_id: UUID) -> ApplicationOverride | None:
        query = select(ApplicationOverride).where(ApplicationOverride.application_id == application_id)
        result = await self.session.execute(query)
        return result.scalar_one_or_none()

    async def upsert(self, application_id: UUID, override_patch: dict) -> ApplicationOverride:
        existing = await self.get_by_application_id(application_id)
        if existing is None:
            entity = ApplicationOverride(application_id=application_id, override_patch=override_patch)
            self.session.add(entity)
        else:
            existing.override_patch = override_patch
            entity = existing

        await self.session.flush()
        await self.session.refresh(entity)
        return entity

    async def commit(self) -> None:
        await self.session.commit()

    async def rollback(self) -> None:
        await self.session.rollback()
