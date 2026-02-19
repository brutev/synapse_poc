from collections.abc import AsyncGenerator

from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase

from src.core.config import get_settings


settings = get_settings()

# Configure engine based on database type
engine_kwargs = {"pool_pre_ping": True}

# SQLite doesn't need connection pooling
if "sqlite" in settings.database_url.lower():
    engine_kwargs = {
        "connect_args": {"check_same_thread": False},
    }

engine = create_async_engine(settings.database_url, **engine_kwargs)
AsyncSessionLocal = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
)


class Base(DeclarativeBase):
    pass


async def get_db_session() -> AsyncGenerator[AsyncSession, None]:
    async with AsyncSessionLocal() as session:
        yield session
