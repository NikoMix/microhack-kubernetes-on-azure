"""Stdlib-only health check used by the Docker HEALTHCHECK directive."""

from __future__ import annotations

import sys
import urllib.request


def main() -> int:
    """Return 0 when /health responds 200, otherwise 1."""
    url = "http://localhost:8080/health"
    try:
        with urllib.request.urlopen(url, timeout=2) as response:  # noqa: S310
            return 0 if response.status == 200 else 1
    except Exception:
        return 1


if __name__ == "__main__":
    sys.exit(main())
