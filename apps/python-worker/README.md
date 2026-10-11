# python-worker

Async **FastAPI** worker for the Kubernetes-on-Azure MicroHack. It polls the
orders API, processes `Pending` orders, and marks them `Completed`. It exposes
health and Prometheus metrics endpoints and supports OpenTelemetry / Azure
Monitor instrumentation. Runs on `0.0.0.0:8080`.

## What it does

- Background worker loop (`worker.py`) runs every `WORKER_POLL_INTERVAL_SECONDS`:
  1. `GET {ORDERS_API_BASEURL}/orders?status=Pending`
  2. For each order: simulate processing, then
     `POST {ORDERS_API_BASEURL}/orders/{id}/status` with `{"status":"Completed"}`
  3. Records Prometheus metrics; never crashes the loop; honors cancellation.
- HTTP endpoints (`app.py`):
  - `GET /health` and `GET /healthz` → `200 {"status":"ok"}` (liveness +
    readiness; returns `503` if the worker task has crashed).
  - `GET /metrics` → Prometheus exposition (`text/plain; version=0.0.4`) from a
    dedicated `CollectorRegistry`.

### Metrics

| Metric | Type | Description |
| --- | --- | --- |
| `orders_processed_total{result}` | Counter | Orders processed (success/failure) |
| `order_processing_seconds` | Histogram | Per-order processing time |
| `worker_poll_total` | Counter | Poll cycles executed |
| `worker_errors_total` | Counter | Errors encountered |
| `orders_inflight` | Gauge | Orders currently being processed |

## Configuration (environment variables)

| Variable | Default | Description |
| --- | --- | --- |
| `ORDERS_API_BASEURL` | `http://dotnet-api:8080` | Orders API base URL |
| `WORKER_POLL_INTERVAL_SECONDS` | `5` | Poll interval (seconds) |
| `OTEL_SERVICE_NAME` | `python-worker` | Service name for telemetry |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | _(unset)_ | OTLP endpoint; enables OTLP export |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | `grpc` | OTLP protocol |
| `APPLICATIONINSIGHTS_CONNECTION_STRING` | _(unset)_ | Enables Azure Monitor export |
| `LOG_LEVEL` | `INFO` | Log level (JSON structured logs) |
| `HTTP_TIMEOUT_SECONDS` | `10` | httpx client timeout |

Telemetry priority: Azure Monitor (if connection string set) → OTLP (if endpoint
set) → no-op. Instrumentation never crashes when nothing is configured.

## Local development

Use a local virtual environment (Python 3.14):

```powershell
py -3.14 -m venv .venv
.\.venv\Scripts\python.exe -m pip install --upgrade pip pip-tools
.\.venv\Scripts\python.exe -m pip install --require-hashes -r requirements.txt -r requirements-dev.txt
```

Recompile hashed lockfiles after changing `requirements*.in`:

```powershell
.\.venv\Scripts\python.exe -m piptools compile --generate-hashes -o requirements.txt requirements.in
.\.venv\Scripts\python.exe -m piptools compile --generate-hashes --allow-unsafe -o requirements-dev.txt requirements-dev.in
```

Run the service:

```powershell
.\.venv\Scripts\python.exe -m uvicorn python_worker.app:app --host 0.0.0.0 --port 8080
```

### Quality gates

```powershell
.\.venv\Scripts\python.exe -m ruff check .
.\.venv\Scripts\python.exe -m ruff format --check .
.\.venv\Scripts\python.exe -m mypy --strict src
.\.venv\Scripts\python.exe -m bandit -r src
.\.venv\Scripts\python.exe -m pytest
.\.venv\Scripts\python.exe -m pip_audit -r requirements.txt
.\.venv\Scripts\python.exe -m pip_audit -r requirements-dev.txt
```

## Container

Multi-stage build on **Chainguard** distroless Python (`cgr.dev/chainguard/python`),
non-root (uid `65532`). `:latest` tracks the current stable CPython (3.14) and is
distroless + non-root. Alternative: `gcr.io/distroless/python3-debian13` if an
older CPython is acceptable.

```powershell
docker build -t python-worker:dev .
docker run --rm -p 8080:8080 python-worker:dev
```

- **Entrypoint:** `python -m uvicorn python_worker.app:app --host 0.0.0.0 --port 8080`
- **Port:** `8080`
- **HEALTHCHECK:** `python /app/healthcheck.py` (stdlib-only GET `/health`)

## Kubernetes (Kustomize)

- Base: `k8s/base/` (namespace `microhack-apps`, no `Namespace` resource).
- Overlays: `k8s/overlays/dev` (replicas 1, HPA 1–3, tag `dev`) and
  `k8s/overlays/prod` (replicas 2, HPA 2–5, tag `stable`).
- ServiceAccount `python-worker` with Workload Identity label and
  `azure.workload.identity/client-id: REPLACE_PYTHON_WORKER_CLIENT_ID`.
- Azure Key Vault CSI `SecretProviderClass` projects
  `APPLICATIONINSIGHTS_CONNECTION_STRING`.

```powershell
kubectl kustomize k8s/overlays/dev
kubectl kustomize k8s/overlays/prod
```

Hardened pod: `runAsNonRoot`, `runAsUser 65532`, `readOnlyRootFilesystem`,
`allowPrivilegeEscalation: false`, `capabilities: drop [ALL]`, seccomp
`RuntimeDefault`, with `emptyDir` at `/tmp`. The Service is annotated for
Prometheus scraping on `/metrics:8080`.
