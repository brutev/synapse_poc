"""initial schema

Revision ID: 0001_initial
Revises:
Create Date: 2026-02-14 00:00:00.000000
"""

from typing import Sequence

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision: str = "0001_initial"
down_revision: str | None = None
branch_labels: Sequence[str] | None = None
depends_on: Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "applications",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("rule_version", sa.String(length=32), nullable=False),
        sa.Column("phase", sa.String(length=64), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.PrimaryKeyConstraint("id"),
    )

    op.create_table(
        "application_section_data",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("application_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("section_id", sa.String(length=128), nullable=False),
        sa.Column("data", postgresql.JSONB(astext_type=sa.Text()), nullable=False),
        sa.ForeignKeyConstraint(["application_id"], ["applications.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("application_id", "section_id", name="uq_app_section_data_app_section"),
    )
    op.create_index("ix_app_section_data_application_id", "application_section_data", ["application_id"], unique=False)
    op.create_index("ix_app_section_data_section_id", "application_section_data", ["section_id"], unique=False)

    op.create_table(
        "application_overrides",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("application_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("override_patch", postgresql.JSONB(astext_type=sa.Text()), nullable=False),
        sa.ForeignKeyConstraint(["application_id"], ["applications.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("application_id", name="uq_application_overrides_application_id"),
    )
    op.create_index("ix_application_overrides_application_id", "application_overrides", ["application_id"], unique=False)


def downgrade() -> None:
    op.drop_index("ix_application_overrides_application_id", table_name="application_overrides")
    op.drop_table("application_overrides")

    op.drop_index("ix_app_section_data_section_id", table_name="application_section_data")
    op.drop_index("ix_app_section_data_application_id", table_name="application_section_data")
    op.drop_table("application_section_data")

    op.drop_table("applications")
