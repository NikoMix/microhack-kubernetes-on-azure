# Delivery diagrams

Use these Mermaid diagrams as the baseline structure for the B.4.1 evidence pack. Replace placeholders with deployed names during the lab.

## Logical diagram

```mermaid
flowchart LR
  user["User or trainer test client"] --> ingress["Ingress host"]
  ingress --> web["node-web\nNode 24 Fastify BFF"]
  web --> api["dotnet-api\n.NET 10 Minimal API"]
  api --> worker["python-worker\nPython 3.14 worker"]
  web --> otel["OpenTelemetry exporter"]
  api --> otel
  worker --> otel
  otel --> monitor["Azure Monitor\nContainer Insights"]
  web --> kv["Key Vault CSI secrets"]
  api --> kv
  worker --> kv
  flux["Flux v2 app-of-apps"] --> web
  flux --> api
  flux --> worker
  acr["Azure Container Registry"] --> web
  acr --> api
  acr --> worker
```

## Physical diagram

```mermaid
flowchart TB
  subgraph azure["Azure subscription <subscription-id>"]
    rg["Resource group <resource-group>"]
    subgraph network["Hub and spoke network in westeurope"]
      firewall["Azure Firewall egress"]
      ingress["App Gateway for Containers or managed NGINX"]
      subnetSystem["AKS system subnet"]
      subnetUser["AKS user subnet"]
    end
    subgraph aks["AKS <cluster-name>"]
      systemPool["System node pool"]
      userPool["User node pool"]
      flux["flux-system namespace"]
      apps["apps namespace"]
      workloadId["Workload Identity service accounts"]
    end
    acr["ACR <acr-login-server>"]
    kv["Key Vault <key-vault-name>"]
    law["Log Analytics workspace"]
    prom["Managed Prometheus"]
    grafana["Managed Grafana"]
  end
  rg --> network
  rg --> aks
  rg --> acr
  rg --> kv
  rg --> law
  ingress --> userPool
  subnetSystem --> systemPool
  subnetUser --> userPool
  userPool --> acr
  workloadId --> kv
  aks --> law
  aks --> prom
  prom --> grafana
  userPool --> firewall
```

## Sequence diagram

```mermaid
sequenceDiagram
  actor Learner
  participant GitHub as GitHub repository
  participant ACR as Azure Container Registry
  participant Flux as Flux v2
  participant AKS as AKS cluster
  participant Monitor as Azure Monitor
  Learner->>ACR: Build and push dotnet-api, python-worker, node-web images
  Learner->>GitHub: Commit or update GitOps app-of-apps image tags
  Flux->>GitHub: Poll Git source and detect revision
  Flux->>AKS: Apply infrastructure and application Kustomizations
  AKS->>ACR: Pull images with managed identity
  AKS->>AKS: Start pods with Workload Identity service accounts
  Learner->>AKS: Verify pods, ingress, and service accounts
  AKS->>Monitor: Send container logs, metrics, and OpenTelemetry
  Learner->>Monitor: Confirm telemetry is flowing
```
