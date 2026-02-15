from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.models.application import Application


class ApplicationRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def create(self, application: Application) -> Application:
        self.session.add(application)
        await self.session.flush()
        await self.session.refresh(application)
        return application

    async def get_by_id(self, application_id: UUID) -> Application | None:
        query = select(Application).where(Application.id == application_id)
        result = await self.session.execute(query)
        return result.scalar_one_or_none()

    async def commit(self) -> None:
        await self.session.commit()

    async def rollback(self) -> None:
        await self.session.rollback()
