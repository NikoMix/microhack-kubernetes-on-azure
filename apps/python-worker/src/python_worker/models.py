"""Pydantic data models for orders."""

from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field


class Order(BaseModel):
    """An order returned by the orders API."""

    model_config = ConfigDict(extra="ignore")

    id: str | int = Field(..., description="Unique order identifier.")
    status: str = Field(..., description="Current order status.")

    @property
    def identifier(self) -> str:
        """Return the order identifier as a string for URL building."""
        return str(self.id)


class StatusUpdate(BaseModel):
    """Payload used to update an order status."""

    status: str = Field(..., description="New order status.")


class HealthResponse(BaseModel):
    """Response body for health endpoints."""

    status: str = "ok"
