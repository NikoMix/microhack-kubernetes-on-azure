"""Prometheus metrics with a dedicated registry."""

from __future__ import annotations

from prometheus_client import CollectorRegistry, Counter, Gauge, Histogram

registry = CollectorRegistry()

orders_processed_total = Counter(
    "orders_processed_total",
    "Total number of orders processed.",
    ["result"],
    registry=registry,
)

order_processing_seconds = Histogram(
    "order_processing_seconds",
    "Time spent processing a single order in seconds.",
    registry=registry,
)

worker_poll_total = Counter(
    "worker_poll_total",
    "Total number of worker poll cycles executed.",
    registry=registry,
)

worker_errors_total = Counter(
    "worker_errors_total",
    "Total number of errors encountered by the worker.",
    registry=registry,
)

orders_inflight = Gauge(
    "orders_inflight",
    "Number of orders currently being processed.",
    registry=registry,
)
