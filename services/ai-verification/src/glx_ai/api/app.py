import logging
import random

from fastapi import FastAPI, HTTPException

from glx_ai.application.readiness import is_ready
from glx_ai.config import Settings


def create_app(settings: Settings | None = None) -> FastAPI:
    runtime_settings = settings or Settings()
    random.seed(runtime_settings.deterministic_seed)
    logging.basicConfig(
        level=logging.INFO,
        format='{"level":"%(levelname)s","message":"%(message)s"}',
    )
    app = FastAPI(title="GLX AI Verification", version="0.1.0")

    @app.get("/healthz")
    def healthz() -> dict[str, str]:  # pyright: ignore[reportUnusedFunction]
        return {"status": "ok"}

    @app.get("/readyz")
    def readyz() -> dict[str, str]:  # pyright: ignore[reportUnusedFunction]
        if not is_ready(runtime_settings):
            raise HTTPException(status_code=503, detail="Model manifest is not ready")
        return {"status": "ready"}

    return app
