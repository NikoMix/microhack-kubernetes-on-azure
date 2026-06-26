"""Application configuration via environment variables."""

from __future__ import annotations

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Runtime configuration loaded from environment variables."""

    model_config = SettingsConfigDict(env_file=None, extra="ignore")

    orders_api_baseurl: str = "http://dotnet-api:8080"
    worker_poll_interval_seconds: float = 5.0
    otel_service_name: str = "python-worker"
    otel_exporter_otlp_endpoint: str | None = None
    otel_exporter_otlp_protocol: str = "grpc"
    applicationinsights_connection_string: str | None = None
    log_level: str = "INFO"
    http_timeout_seconds: float = 10.0


def get_settings() -> Settings:
    """Return a freshly loaded :class:`Settings` instance."""
    return Settings()
