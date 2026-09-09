# pyright: reportUnknownMemberType=false

from pathlib import Path

from fastapi.testclient import TestClient

from glx_ai.api.app import create_app
from glx_ai.config import Settings


def test_fake_local_profile_is_healthy_and_ready() -> None:
    client = TestClient(create_app(Settings(fake_readiness=True, deterministic_seed=42)))

    assert client.get("/healthz").json() == {"status": "ok"}
    assert client.get("/readyz").json() == {"status": "ready"}


def test_real_profile_rejects_missing_model_manifest() -> None:
    settings = Settings(fake_readiness=False, model_manifest_path=Path("missing.json"))
    client = TestClient(create_app(settings))

    assert client.get("/readyz").status_code == 503
