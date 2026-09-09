from pathlib import Path

from glx_ai.config import Settings


def is_ready(settings: Settings) -> bool:
    if settings.fake_readiness:
        return True
    manifest: Path | None = settings.model_manifest_path
    return manifest is not None and manifest.is_file()
