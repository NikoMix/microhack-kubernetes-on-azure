"""Shared pytest fixtures."""

from __future__ import annotations

from collections.abc import Callable

import pytest

from python_worker.config import Settings

SettingsFactory = Callable[..., Settings]


@pytest.fixture
def make_settings() -> SettingsFactory:
    """Return a factory that builds Settings with test defaults."""

    def _factory(**overrides: object) -> Settings:
        base: dict[str, object] = {
            "orders_api_baseurl": "http://orders.test",
            "worker_poll_interval_seconds": 0.01,
            "http_timeout_seconds": 1.0,
        }
        base.update(overrides)
        return Settings(**base)  # type: ignore[arg-type]

    return _factory
