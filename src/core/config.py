import os
from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "Loan Origination POC"
    app_env: str = os.getenv("APP_ENV", "development")
    
    # Database URL - defaults to SQLite for dev, can use PostgreSQL via env var
    database_url: str = os.getenv(
        "DATABASE_URL",
        "sqlite+aiosqlite:///./loan_poc.db"  # SQLite default for dev
    )

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )


@lru_cache
def get_settings() -> Settings:
    return Settings()
