from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from src.core.database import get_db_session
from src.repositories.application_override_repository import ApplicationOverrideRepository
from src.repositories.application_repository import ApplicationRepository
from src.repositories.application_section_data_repository import ApplicationSectionDataRepository
from src.services.action_service import ActionService
from src.services.application_service import ApplicationService
from src.services.evaluate_service import EvaluateService
from src.services.rule_service import RuleService
from src.services.save_draft_service import SaveDraftService
from src.services.submit_service import SubmitService


async def get_application_service(
    session: AsyncSession = Depends(get_db_session),
) -> ApplicationService:
    repository = ApplicationRepository(session)
    return ApplicationService(repository)


async def get_evaluate_service(
    session: AsyncSession = Depends(get_db_session),
) -> EvaluateService:
    app_repository = ApplicationRepository(session)
    section_data_repository = ApplicationSectionDataRepository(session)
    override_repository = ApplicationOverrideRepository(session)
    rule_service = RuleService(section_data_repository, override_repository)
    return EvaluateService(app_repository, rule_service)


async def get_action_service(
    session: AsyncSession = Depends(get_db_session),
) -> ActionService:
    app_repository = ApplicationRepository(session)
    section_data_repository = ApplicationSectionDataRepository(session)
    return ActionService(app_repository, section_data_repository)


async def get_save_draft_service(
    session: AsyncSession = Depends(get_db_session),
) -> SaveDraftService:
    app_repository = ApplicationRepository(session)
    section_data_repository = ApplicationSectionDataRepository(session)
    return SaveDraftService(app_repository, section_data_repository)


async def get_submit_service(
    session: AsyncSession = Depends(get_db_session),
) -> SubmitService:
    app_repository = ApplicationRepository(session)
    section_data_repository = ApplicationSectionDataRepository(session)
    override_repository = ApplicationOverrideRepository(session)
    rule_service = RuleService(section_data_repository, override_repository)
    return SubmitService(app_repository, rule_service)
