"""Background worker that processes Pending orders."""

from __future__ import annotations

import asyncio
import logging

import httpx

from . import metrics
from .config import Settings
from .models import Order, StatusUpdate

logger = logging.getLogger(__name__)

_PROCESSING_DELAY_SECONDS = 0.05


class Worker:
    """Polls the orders API and completes Pending orders."""

    def __init__(self, settings: Settings) -> None:
        self._settings = settings
        self._client = httpx.AsyncClient(
            base_url=settings.orders_api_baseurl,
            timeout=settings.http_timeout_seconds,
        )

    async def aclose(self) -> None:
        """Close the underlying HTTP client."""
        await self._client.aclose()

    async def run(self) -> None:
        """Run the poll loop until cancelled."""
        logger.info(
            "worker started",
            extra={"poll_interval": self._settings.worker_poll_interval_seconds},
        )
        try:
            while True:
                await self._poll_once_safe()
                await asyncio.sleep(self._settings.worker_poll_interval_seconds)
        except asyncio.CancelledError:
            logger.info("worker cancelled; shutting down")
            raise

    async def _poll_once_safe(self) -> None:
        metrics.worker_poll_total.inc()
        try:
            await self.poll_once()
        except asyncio.CancelledError:
            raise
        except Exception:
            metrics.worker_errors_total.inc()
            logger.exception("error during poll cycle")

    async def poll_once(self) -> int:
        """Fetch and process Pending orders once. Returns count processed."""
        orders = await self._fetch_pending()
        processed = 0
        for order in orders:
            await self._process_order(order)
            processed += 1
        return processed

    async def _fetch_pending(self) -> list[Order]:
        response = await self._client.get("/orders", params={"status": "Pending"})
        response.raise_for_status()
        data = response.json()
        return [Order.model_validate(item) for item in data]

    async def _process_order(self, order: Order) -> None:
        metrics.orders_inflight.inc()
        try:
            with metrics.order_processing_seconds.time():
                await asyncio.sleep(_PROCESSING_DELAY_SECONDS)
                await self._mark_completed(order)
            metrics.orders_processed_total.labels(result="success").inc()
            logger.info("order processed", extra={"order_id": order.identifier})
        except asyncio.CancelledError:
            raise
        except Exception:
            metrics.orders_processed_total.labels(result="failure").inc()
            metrics.worker_errors_total.inc()
            logger.exception("failed to process order", extra={"order_id": order.identifier})
        finally:
            metrics.orders_inflight.dec()

    async def _mark_completed(self, order: Order) -> None:
        payload = StatusUpdate(status="Completed")
        response = await self._client.post(
            f"/orders/{order.identifier}/status",
            json=payload.model_dump(),
        )
        response.raise_for_status()
