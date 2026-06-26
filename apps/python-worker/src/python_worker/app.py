"""FastAPI application wiring the worker, health, and metrics endpoints."""

from __future__ import annotations

import asyncio
import contextlib
import logging
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from fastapi import FastAPI, Response
from prometheus_client import CONTENT_TYPE_LATEST, generate_latest

from . import metrics
from .config import get_settings
from .logging_config import configure_logging
from .models import HealthResponse
from .telemetry import configure_telemetry, instrument_fastapi
from .worker import Worker

logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    """Start and stop the background worker around the app lifecycle."""
    settings = get_settings()
    configure_logging(settings.log_level)
    configure_telemetry(settings)

    worker = Worker(settings)
    task = asyncio.create_task(worker.run(), name="order-worker")
    app.state.worker = worker
    app.state.worker_task = task
    logger.info("application startup complete")
    try:
        yield
    finally:
        task.cancel()
        with contextlib.suppress(asyncio.CancelledError):
            await task
        await worker.aclose()
        logger.info("application shutdown complete")


app = FastAPI(title="python-worker", version="0.1.0", lifespan=lifespan)
instrument_fastapi(app)


def _worker_healthy() -> bool:
    task: asyncio.Task[None] | None = getattr(app.state, "worker_task", None)
    if task is None:
        return False
    return not (task.done() and task.exception() is not None)


@app.get("/health", response_model=HealthResponse)
@app.get("/healthz", response_model=HealthResponse)
async def health() -> Response:
    """Liveness and readiness probe; confirms the worker task is alive."""
    if not _worker_healthy():
        return Response(
            content=HealthResponse(status="unhealthy").model_dump_json(),
            media_type="application/json",
            status_code=503,
        )
    return Response(
        content=HealthResponse(status="ok").model_dump_json(),
        media_type="application/json",
        status_code=200,
    )


@app.get("/metrics")
async def prometheus_metrics() -> Response:
    """Expose Prometheus metrics from the dedicated registry."""
    return Response(content=generate_latest(metrics.registry), media_type=CONTENT_TYPE_LATEST)
