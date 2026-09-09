from pathlib import Path

from pydantic import model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Non-sensitive runtime configuration; model and image content are never logged."""

    model_config = SettingsConfigDict(env_prefix="GLX_AI_", case_sensitive=False)

    environment: str = "local"
    fake_readiness: bool = True
    model_manifest_path: Path | None = None
    deterministic_seed: int = 42

    @model_validator(mode="after")
    def require_manifest_for_real_readiness(self) -> "Settings":
        if not self.fake_readiness and self.model_manifest_path is None:
            raise ValueError(
                "GLX_AI_MODEL_MANIFEST_PATH is required when fake readiness is disabled"
            )
        return self
