"""Optional OpenTelemetry / Azure Monitor instrumentation.

This module configures tracing/metrics export based on environment
configuration. It is designed to never crash when nothing is configured
(for example, during offline test runs).
"""

from __future__ import annotations

import logging
from typing import TYPE_CHECKING, Any

from .config import Settings

if TYPE_CHECKING:
    from fastapi import FastAPI

logger = logging.getLogger(__name__)


def configure_telemetry(settings: Settings) -> None:
    """Configure telemetry exporters based on ``settings``.

    Priority:
      1. Azure Monitor when ``APPLICATIONINSIGHTS_CONNECTION_STRING`` is set.
      2. OTLP exporter when ``OTEL_EXPORTER_OTLP_ENDPOINT`` is set.
      3. No-op otherwise.
    """
    if settings.applicationinsights_connection_string:
        _configure_azure_monitor(settings)
    elif settings.otel_exporter_otlp_endpoint:
        _configure_otlp(settings)
    else:
        logger.info("telemetry disabled: no exporter configured")

    _instrument_libraries()


def _configure_azure_monitor(settings: Settings) -> None:
    try:
        from azure.monitor.opentelemetry import configure_azure_monitor

        configure_azure_monitor(
            connection_string=settings.applicationinsights_connection_string,
            service_name=settings.otel_service_name,
        )
        logger.info("telemetry enabled via Azure Monitor")
    except Exception:  # pragma: no cover - defensive, network/optional dep
        logger.exception("failed to configure Azure Monitor; continuing without it")


def _configure_otlp(settings: Settings) -> None:
    try:
        from opentelemetry import trace
        from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import (
            OTLPSpanExporter,
        )
        from opentelemetry.sdk.resources import Resource
        from opentelemetry.sdk.trace import TracerProvider
        from opentelemetry.sdk.trace.export import BatchSpanProcessor

        resource = Resource.create({"service.name": settings.otel_service_name})
        provider = TracerProvider(resource=resource)
        exporter = OTLPSpanExporter(endpoint=settings.otel_exporter_otlp_endpoint)
        provider.add_span_processor(BatchSpanProcessor(exporter))
        trace.set_tracer_provider(provider)
        logger.info(
            "telemetry enabled via OTLP exporter at %s",
            settings.otel_exporter_otlp_endpoint,
        )
    except Exception:  # pragma: no cover - defensive, network/optional dep
        logger.exception("failed to configure OTLP exporter; continuing without it")


def _instrument_libraries() -> None:
    try:
        from opentelemetry.instrumentation.httpx import HTTPXClientInstrumentor

        HTTPXClientInstrumentor().instrument()
    except Exception:  # pragma: no cover - defensive
        logger.debug("httpx instrumentation unavailable", exc_info=True)

    try:
        from opentelemetry.instrumentation.logging import LoggingInstrumentor

        LoggingInstrumentor().instrument(set_logging_format=False)
    except Exception:  # pragma: no cover - defensive
        logger.debug("logging instrumentation unavailable", exc_info=True)


def instrument_fastapi(app: FastAPI) -> None:
    """Instrument a FastAPI application if instrumentation is available."""
    try:
        from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor

        instrumentor: Any = FastAPIInstrumentor()
        instrumentor.instrument_app(app)
    except Exception:  # pragma: no cover - defensive
        logger.debug("fastapi instrumentation unavailable", exc_info=True)
