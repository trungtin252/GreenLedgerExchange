FROM python:3.11.5-slim AS builder
COPY --from=ghcr.io/astral-sh/uv:0.8.22@sha256:9874eb7afe5ca16c363fe80b294fe700e460df29a55532bbfea234a0f12eddb1 /uv /uvx /bin/
WORKDIR /build
ENV UV_PROJECT_ENVIRONMENT=/app/.venv
COPY pyproject.toml uv.lock* ./
RUN uv sync --frozen --no-dev
COPY src ./src

FROM python:3.11.5-slim
LABEL org.opencontainers.image.title="glx-ai-verification"
WORKDIR /app
RUN useradd --create-home --uid 10001 glx && mkdir /tmp/glx && chown -R glx:glx /app /tmp/glx
COPY --from=builder /app/.venv /app/.venv
COPY --from=builder /build/src /app/src
USER 10001
ENV PATH="/app/.venv/bin:$PATH" TMPDIR=/tmp/glx PYTHONPATH=/app/src
EXPOSE 8090
HEALTHCHECK --interval=10s --timeout=3s --retries=10 CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8090/healthz')"
CMD ["uvicorn", "glx_ai.main:app", "--host", "0.0.0.0", "--port", "8090"]
