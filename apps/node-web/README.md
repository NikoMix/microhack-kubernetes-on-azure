# node-web

A Node 24 + Fastify **BFF / front door** for the Kubernetes-on-Azure MicroHack. It calls the
downstream `dotnet-api` orders service and renders a server-side (SSR) HTML status page showing the
downstream health and the current orders. It is intentionally resilient: if the downstream is
unavailable the front door stays up and renders a graceful error state (HTTP 200).

Written in **ESM + TypeScript (strict)**, runs on **Node >= 24**, listens on `0.0.0.0:8080`.

## Endpoints

| Method | Path      | Description                                                    |
| ------ | --------- | -------------------------------------------------------------- |
| GET    | `/health` | Liveness + readiness probe. Returns `200 { "status": "ok" }`.  |
| GET    | `/`       | SSR HTML status page (orders table + downstream health badge). |

## Configuration

All configuration is via environment variables (see `src/config.ts`).

| Variable                                | Default                  | Description                                           |
| --------------------------------------- | ------------------------ | ----------------------------------------------------- |
| `PORT`                                  | `8080`                   | TCP port the server listens on.                       |
| `ORDERS_API_BASEURL`                    | `http://dotnet-api:8080` | Base URL of the downstream orders API.                |
| `REQUEST_TIMEOUT_MS`                    | `5000`                   | Per-request timeout (AbortController) for downstream. |
| `OTEL_SERVICE_NAME`                     | `node-web`               | OpenTelemetry service name.                           |
| `OTEL_EXPORTER_OTLP_ENDPOINT`           | _(unset)_                | OTLP collector endpoint. Enables OTel when set.       |
| `OTEL_EXPORTER_OTLP_PROTOCOL`           | `grpc`                   | `grpc` or `http/protobuf`.                            |
| `APPLICATIONINSIGHTS_CONNECTION_STRING` | _(unset)_                | If set, uses Azure Monitor instead of raw OTLP.       |

### Telemetry selection (`src/telemetry.ts`)

Initialized **before** Fastify (the telemetry import is first in `server.ts`):

1. `APPLICATIONINSIGHTS_CONNECTION_STRING` set → `@azure/monitor-opentelemetry` `useAzureMonitor()`.
2. else `OTEL_EXPORTER_OTLP_ENDPOINT` set → `@opentelemetry/sdk-node` NodeSDK + auto-instrumentations
   with an OTLP trace exporter (gRPC or proto/HTTP, matching `OTEL_EXPORTER_OTLP_PROTOCOL`).
3. else → no-op. Telemetry never crashes the process offline.

## Develop / build / test

```pwsh
npm install        # installs deps and generates package-lock.json
npm run dev        # watch mode (Node 24 native TS), http://localhost:8080
npm run typecheck  # tsc --noEmit
npm run lint       # eslint . (typescript-eslint strict-type-checked + stylistic)
npm run format:check
npm test           # vitest run
npm run build      # tsc -> dist/
npm start          # node dist/server.js
npm audit          # zero vulnerabilities expected
```

The HTTP client uses the Node built-in global `fetch` (undici) — no extra HTTP dependency.

## Container

Multi-stage `Dockerfile`:

- **build stage:** `node:24-trixie-slim`, `npm ci`, `npm run build`, then `npm prune --omit=dev`.
- **runtime stage:** `gcr.io/distroless/nodejs24-debian13:nonroot` (non-root uid `65532`, no shell).

The distroless `nodejs` image sets `ENTRYPOINT ["node"]`, so `CMD` and `HEALTHCHECK CMD` arrays are
passed as arguments to `node`:

- `CMD ["dist/server.js"]` → `node dist/server.js`
- `HEALTHCHECK CMD ["dist/healthcheck.js"]` → `node dist/healthcheck.js` (probes `/health`, exits 0/1).

```pwsh
docker build -t node-web:dev .
docker run --rm -p 8080:8080 node-web:dev
```

## Kubernetes (Kustomize)

```
k8s/
  base/        deployment, service (ClusterIP 80->8080 http), serviceaccount,
               hpa (CPU 70%), configmap, secretproviderclass, kustomization
  overlays/
    dev/       replicas 1, HPA 1/3, image tag dev, Ingress node-web.dev.microhack.local
    prod/      replicas 2, HPA 2/5, image tag stable, Ingress microhack.example.com (TLS + cert-manager)
```

- Namespace is `microhack-apps` (set in kustomizations; no Namespace resource is created).
- **ServiceAccount:** `node-web`, labelled `azure.workload.identity/use: "true"` with annotation
  `azure.workload.identity/client-id: "REPLACE_NODE_WEB_CLIENT_ID"` (replace per environment).
- Pod security: runAsNonRoot, uid 65532, `readOnlyRootFilesystem: true` (writable `emptyDir` at `/tmp`),
  `allowPrivilegeEscalation: false`, all capabilities dropped, `seccompProfile: RuntimeDefault`.
- `secretproviderclass.yaml` is included for parity (projects `APPLICATIONINSIGHTS_CONNECTION_STRING`
  from Key Vault via the Secrets Store CSI driver); it is not mounted by default.

Render and validate:

```pwsh
kubectl kustomize k8s/overlays/dev
kubectl kustomize k8s/overlays/prod
```

## Project layout

```
src/
  server.ts        Fastify app + listen (imports telemetry first)
  telemetry.ts     OTel / Azure Monitor bootstrap (import-time side effect)
  config.ts        typed env configuration
  ordersClient.ts  downstream client (global fetch + AbortController)
  views.ts         pure SSR HTML functions (HTML-escaped)
  healthcheck.ts   container HEALTHCHECK script (probes /health)
test/              vitest suites (health route, views, ordersClient)
```
