"""Tests for config, models, logging, and telemetry."""

from __future__ import annotations

import json
import logging

from python_worker.config import Settings, get_settings
from python_worker.logging_config import JsonFormatter, configure_logging
from python_worker.models import HealthResponse, Order, StatusUpdate
from python_worker.telemetry import configure_telemetry


def test_settings_defaults() -> None:
    settings = get_settings()
    assert settings.orders_api_baseurl == "http://dotnet-api:8080"
    assert settings.worker_poll_interval_seconds == 5.0
    assert settings.otel_service_name == "python-worker"


def test_settings_env_override(monkeypatch) -> None:  # type: ignore[no-untyped-def]
    monkeypatch.setenv("ORDERS_API_BASEURL", "http://example:9000")
    monkeypatch.setenv("LOG_LEVEL", "DEBUG")
    settings = Settings()
    assert settings.orders_api_baseurl == "http://example:9000"
    assert settings.log_level == "DEBUG"


def test_order_identifier_coerces_int() -> None:
    order = Order(id=7, status="Pending")
    assert order.identifier == "7"


def test_models_roundtrip() -> None:
    assert StatusUpdate(status="Completed").model_dump() == {"status": "Completed"}
    assert HealthResponse().status == "ok"


def test_json_formatter_outputs_valid_json() -> None:
    formatter = JsonFormatter()
    record = logging.LogRecord(
        name="test",
        level=logging.INFO,
        pathname=__file__,
        lineno=1,
        msg="hello %s",
        args=("world",),
        exc_info=None,
    )
    payload = json.loads(formatter.format(record))
    assert payload["message"] == "hello world"
    assert payload["level"] == "INFO"


def test_configure_logging_sets_level() -> None:
    configure_logging("WARNING")
    assert logging.getLogger().level == logging.WARNING
    configure_logging("INFO")


def test_configure_telemetry_noop_when_unconfigured() -> None:
    configure_telemetry(Settings(applicationinsights_connection_string=None))
