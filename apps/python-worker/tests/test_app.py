"""Tests for the FastAPI application endpoints."""

from __future__ import annotations

import httpx
import respx
from asgi_lifespan import LifespanManager

from python_worker.app import app


@respx.mock
async def test_health_and_metrics_endpoints() -> None:
    respx.get("http://dotnet-api:8080/orders").mock(return_value=httpx.Response(200, json=[]))
    transport = httpx.ASGITransport(app=app)
    async with (
        LifespanManager(app),
        httpx.AsyncClient(transport=transport, base_url="http://test") as client,
    ):
        health = await client.get("/health")
        assert health.status_code == 200
        assert health.json() == {"status": "ok"}

        healthz = await client.get("/healthz")
        assert healthz.status_code == 200

        metrics_resp = await client.get("/metrics")
        assert metrics_resp.status_code == 200
        assert "text/plain" in metrics_resp.headers["content-type"]
        assert "worker_poll_total" in metrics_resp.text
