# `apps/` — Polyglot sample workloads

A small, realistic microservices set that the labs **assess → design → migrate → test →
operate**, exercising Module B end‑to‑end.

| Service | Stack | Role |
|---|---|---|
| `dotnet-api` | **.NET 10** / ASP.NET Core Minimal API | Public REST API (orders), exposes `/health` liveness + readiness, OpenAPI |
| `python-worker` | **Python 3.14** / FastAPI | Async worker/processor, queue consumer, metrics endpoint |
| `node-web` | **Node 24** / Fastify | Web BFF / front door calling the API, server‑rendered status page |

## Requirements
- **Distroless / Chiseled** multi‑stage Dockerfiles; non‑root; healthchecks.
- **OpenTelemetry** traces/metrics/logs → Azure Monitor (OTLP).
- Config via env + Key Vault CSI; **no secrets in images**.
- Helm chart **or** Kustomize base+overlays per service for AKS deploy.
- Latest dependencies, **zero known vulnerabilities**, permissive licenses only.

### Optional AI capability
If any service adds an AI endpoint, it must use a **modular inference provider**
abstraction supporting **Azure AI Foundry / Azure OpenAI / GitHub Models** (selectable via
config), per the course standing rules.

> Owned by workstream **WS2 (Apps)**.
