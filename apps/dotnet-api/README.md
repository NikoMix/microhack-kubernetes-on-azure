# `dotnet-api` — Orders microservice (.NET 10)

ASP.NET Core **Minimal API** for the "orders" domain, part of the
**Kubernetes-on-Azure MicroHack** (`apps/`, workstream WS2). It exposes a small REST API,
health/readiness probes, OpenAPI + Scalar docs, OpenTelemetry, and an **optional, modular
AI inference** capability (disabled by default).

The container listens on `0.0.0.0:8080`.

## Endpoints

| Method | Path | Description |
|---|---|---|
| `GET` | `/` | Redirects to the Scalar API reference UI. |
| `GET` | `/scalar` | Scalar interactive API docs. |
| `GET` | `/openapi/v1.json` | OpenAPI 3 document. |
| `GET` | `/orders?status=` | List orders, optional `status` filter (`Pending`/`Processing`/`Completed`/`Cancelled`). |
| `GET` | `/orders/{id}` | Get one order → `200` / `404`. |
| `POST` | `/orders` | Create order (`CreateOrderRequest`) → `201` + `Location`, status `Pending`; `400` ValidationProblem on invalid input. |
| `POST` | `/orders/{id}/status` | Update status (`UpdateStatusRequest`) → `200` / `404`. Used by `python-worker` to mark `Completed`. |
| `POST` | `/orders/{id}/insights` | AI summary of an order → `200`; `404` unknown id; `503` when AI disabled; `502` on upstream failure. |
| `GET` | `/healthz`, `/health` | Liveness (always healthy if the process is alive). JSON. |
| `GET` | `/readyz` | Readiness (healthy once the repository is initialized). JSON. |

### Models

`Order` (record): `Id` (Guid), `Customer`, `Sku`, `Quantity`, `Status` (`OrderStatus`),
`CreatedAtUtc`, `UpdatedAtUtc`. DTOs: `CreateOrderRequest`, `UpdateStatusRequest`.
Storage is an in-memory, thread-safe `ConcurrentDictionary` (`InMemoryOrderRepository`)
seeded with 5 sample orders, behind `IOrderRepository` so a database implementation can be
swapped in later.

## Configuration / environment

| Variable / key | Default | Purpose |
|---|---|---|
| `ASPNETCORE_URLS` / `ASPNETCORE_HTTP_PORTS` | `http://0.0.0.0:8080` | Listen address (falls back to 8080). |
| `OTEL_SERVICE_NAME` | `dotnet-api` | OpenTelemetry service name. |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | — | When set, OTLP exporter for traces/metrics/logs. |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | `grpc` (k8s) | OTLP protocol. |
| `APPLICATIONINSIGHTS_CONNECTION_STRING` | — | When set, uses the Azure Monitor OpenTelemetry distro instead of raw OTLP. |
| `AI__Provider` | `Disabled` | AI provider: `Disabled` / `AzureOpenAI` / `AzureAIFoundry` / `GitHubModels`. |
| `AI__Endpoint` | — | Provider endpoint URI. |
| `AI__Model` | — | Model id (Azure AI Foundry / GitHub Models). |
| `AI__DeploymentName` | — | Deployment name (Azure OpenAI). |
| `AI__ApiKey` | — | API key / token (from env or Key Vault). |

> Telemetry is **graceful**: when neither Application Insights nor an OTLP endpoint is
> configured, instrumentation is registered but nothing is exported — so tests run offline
> and the app never throws at startup.

### AI provider configuration

AI is **off by default** (`AI:Provider = Disabled`), honoring the course standing rule.
`/orders/{id}/insights` returns `503` until a provider is configured. The provider is
selected by `ChatInferenceProviderFactory` via the Options pattern (`AiOptions`):

| Provider | Client package | Auth | Key settings |
|---|---|---|---|
| `AzureOpenAI` | `Azure.AI.OpenAI` | API key | `Endpoint`, `DeploymentName`, `ApiKey` |
| `AzureAIFoundry` | `Azure.AI.Inference` | `AzureKeyCredential` | `Endpoint`, `Model`, `ApiKey` |
| `GitHubModels` | `Azure.AI.Inference` | `AzureKeyCredential` (token) | `Endpoint` (e.g. `https://models.github.ai/inference`), `Model`, `ApiKey` |

All providers implement `IChatInferenceProvider`. No image generation.

## Run / test / build

```powershell
# from apps/dotnet-api
dotnet restore
dotnet build -c Release -warnaserror
dotnet test  -c Release
dotnet run --project src/DotnetApi          # browse http://localhost:8080/

# quality gates
dotnet format --verify-no-changes
dotnet list package --vulnerable --include-transitive
dotnet list package --outdated
```

Published assembly / DLL: **`DotnetApi.dll`** (`AssemblyName=DotnetApi`).

## Container

Multi-stage build on a **chiseled, non-root** runtime
(`mcr.microsoft.com/dotnet/aspnet:10.0-noble-chiseled`, uid 1654 / `$APP_UID`):

```powershell
docker build -t dotnet-api:dev .
docker run --rm -p 8080:8080 dotnet-api:dev
```

- Entrypoint: `["dotnet", "DotnetApi.dll"]`, port `8080`.
- `HEALTHCHECK` runs the shell-less probe `dotnet DotnetApi.dll healthcheck`, which performs
  an HTTP GET to `http://127.0.0.1:8080/healthz` (2s timeout, exit 0/1) **without** starting
  Kestrel — suitable for distroless/chiseled images.

## Kubernetes (Kustomize)

```text
k8s/
├─ base/                      # deployment, service (ClusterIP 80→http:8080), serviceaccount,
│                             # hpa (autoscaling/v2, CPU 70%), configmap, secretproviderclass
├─ overlays/dev/              # replicas=1, HPA 1–3, image tag `dev`, dev OTLP endpoint
└─ overlays/prod/             # replicas=2, HPA 2–5, higher limits, image tag `stable`
```

- The **Namespace is not** included here (owned by the gitops layer); the base sets
  `namespace: microhack-apps`.
- `ServiceAccount` name **`dotnet-api`** with Azure Workload Identity:
  label `azure.workload.identity/use: "true"` and annotation
  `azure.workload.identity/client-id: "REPLACE_DOTNET_API_CLIENT_ID"`.
- Secrets are sourced from **Azure Key Vault via the Secrets Store CSI driver**
  (`secretproviderclass.yaml`), projected to a `Secret` (`dotnet-api-secrets`) and consumed
  via `envFrom` (commented until infra is wired). Placeholders: `keyvaultName`, `tenantId`,
  `clientID`.
- Pod hardening: `runAsNonRoot`, `runAsUser: 1654`, `readOnlyRootFilesystem: true` (+ `/tmp`
  `emptyDir`), `allowPrivilegeEscalation: false`, drop `ALL` capabilities, `seccompProfile:
  RuntimeDefault`. Probes: liveness `/healthz`, readiness `/readyz`, startup `/healthz`.

Validate the overlays:

```powershell
kubectl kustomize k8s/overlays/dev
kubectl kustomize k8s/overlays/prod
```
