import uuid
from typing import Any

from sqlalchemy import ForeignKey, Index, String, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.types import JSON

from src.core.database import Base


class ApplicationSectionData(Base):
    __tablename__ = "application_section_data"
    __table_args__ = (
        UniqueConstraint("application_id", "section_id", name="uq_app_section_data_app_section"),
        Index("ix_app_section_data_application_id", "application_id"),
        Index("ix_app_section_data_section_id", "section_id"),
    )

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    application_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("applications.id", ondelete="CASCADE"),
        nullable=False,
    )
    section_id: Mapped[str] = mapped_column(String(128), nullable=False)
    data: Mapped[dict[str, Any]] = mapped_column(JSON, nullable=False, default=dict)

    application = relationship("Application", back_populates="section_data")
