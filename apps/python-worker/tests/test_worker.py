"""Tests for the background worker."""

from __future__ import annotations

import httpx
import respx

from python_worker import metrics
from python_worker.worker import Worker

from .conftest import SettingsFactory


@respx.mock
async def test_poll_once_processes_pending_orders(make_settings: SettingsFactory) -> None:
    base = "http://orders.test"
    list_route = respx.get(f"{base}/orders", params={"status": "Pending"}).mock(
        return_value=httpx.Response(
            200,
            json=[{"id": "1", "status": "Pending"}, {"id": 2, "status": "Pending"}],
        )
    )
    status1 = respx.post(f"{base}/orders/1/status").mock(return_value=httpx.Response(200))
    status2 = respx.post(f"{base}/orders/2/status").mock(return_value=httpx.Response(200))

    worker = Worker(make_settings())
    try:
        processed = await worker.poll_once()
    finally:
        await worker.aclose()

    assert processed == 2
    assert list_route.called
    assert status1.called
    assert status2.called
    assert status1.calls.last.request.read() == b'{"status":"Completed"}'


@respx.mock
async def test_poll_once_empty(make_settings: SettingsFactory) -> None:
    base = "http://orders.test"
    respx.get(f"{base}/orders").mock(return_value=httpx.Response(200, json=[]))
    worker = Worker(make_settings())
    try:
        processed = await worker.poll_once()
    finally:
        await worker.aclose()
    assert processed == 0


@respx.mock
async def test_poll_once_safe_swallows_errors(make_settings: SettingsFactory) -> None:
    base = "http://orders.test"
    respx.get(f"{base}/orders").mock(return_value=httpx.Response(500))
    worker = Worker(make_settings())
    before = metrics.worker_errors_total._value.get()
    try:
        await worker._poll_once_safe()
    finally:
        await worker.aclose()
    after = metrics.worker_errors_total._value.get()
    assert after == before + 1
