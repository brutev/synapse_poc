import uuid
from typing import Any

from sqlalchemy import ForeignKey, Index, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.types import JSON

from src.core.database import Base


class ApplicationOverride(Base):
    __tablename__ = "application_overrides"
    __table_args__ = (
        UniqueConstraint("application_id", name="uq_application_overrides_application_id"),
        Index("ix_application_overrides_application_id", "application_id"),
    )

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    application_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("applications.id", ondelete="CASCADE"),
        nullable=False,
    )
    override_patch: Mapped[dict[str, Any]] = mapped_column(JSON, nullable=False, default=dict)

    application = relationship("Application", back_populates="override")
