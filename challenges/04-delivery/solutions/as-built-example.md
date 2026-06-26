# As-built example

This trainer-only example shows the expected level of detail for Control B.4.1 evidence.

## Document control

| Field | Value |
| --- | --- |
| Customer or cohort | Contoso retail platform cohort |
| Prepared by | Trainer reference |
| Date | 2026-06-26 |
| Control | B.4.1 Delivery |
| Source of truth | Azure MCP, GitHub MCP, `az`, `kubectl`, and Flux output |

## Environment

| Item | Value |
| --- | --- |
| Subscription ID | `11111111-2222-3333-4444-555555555555` |
| Tenant ID | `aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee` |
| Region | `westeurope` |
| Resource group | `rg-microhack-b4-weu` |
| Deployment track | Bicep primary |
| GitOps repository | `https://github.com/contoso/aks-microhack-gitops.git` |
| GitOps branch | `main` |
| GitOps path | `gitops/clusters/microhack` |

## Resources deployed

| Resource type | Name | Purpose | Evidence source |
| --- | --- | --- | --- |
| AKS cluster | `aks-mh-b4-weu-001` | Secure workload platform with system and user node pools | `az aks show` and Azure MCP resource read |
| Azure Container Registry | `acrmhb4weu001` | Private image registry for workshop services | `az acr show` |
| Key Vault | `kv-mh-b4-weu-001` | Secrets provider for CSI Secret Store | Azure MCP resource read |
| Log Analytics workspace | `law-mh-b4-weu-001` | Container Insights and diagnostics | Azure Monitor workspace read |
| Managed Grafana | `grafana-mh-b4-weu-001` | Metrics dashboards for platform telemetry | Azure MCP resource read |

## Identities

| Identity | Scope | Permission or use | Validation |
| --- | --- | --- | --- |
| AKS control plane identity | Resource group | Cluster resource management | Identity listed on cluster resource |
| Kubelet identity | ACR scope | `AcrPull` | Role assignment present on `acrmhb4weu001` |
| `node-web-sa` | `apps` namespace | Federated Workload Identity for Azure Monitor export | Service account annotation includes client ID |
| `dotnet-api-sa` | `apps` namespace | Federated Workload Identity for Key Vault and telemetry | Service account annotation includes client ID |
| `python-worker-sa` | `apps` namespace | Federated Workload Identity for queue and telemetry calls | Service account annotation includes client ID |

## Network

| Area | Delivered state | Evidence |
| --- | --- | --- |
| VNet and subnets | Hub and spoke VNet with AKS system and user subnets in West Europe | VNet and subnet list from Azure MCP |
| Pod networking | Azure CNI Overlay enabled | `networkProfile.networkPluginMode` shows overlay |
| API server access | API-server VNet integration enabled for private platform path | AKS network profile output |
| Egress | Azure Firewall used for controlled outbound traffic | Route table and firewall resource read |
| Policy and Defender | Azure Policy for AKS and Defender for Containers enabled | Defender and policy extension status |

## Ingress

| Item | Value |
| --- | --- |
| Ingress implementation | App Gateway for Containers |
| Hostname | `shop.mh-b4.contoso.example` |
| TLS or certificate source | Managed certificate from approved issuer |
| Health endpoint tested | `https://shop.mh-b4.contoso.example/health` |
| Result | HTTP 200 at 2026-06-26 14:43 CEST |

## Images and versions

| Service | Runtime | Image | Tag | Build method | Verification |
| --- | --- | --- | --- | --- | --- |
| dotnet-api | .NET 10 | `acrmhb4weu001.azurecr.io/dotnet-api` | `m4-202606261405` | `az acr build` | Tag listed in ACR and pod image field |
| python-worker | Python 3.14 | `acrmhb4weu001.azurecr.io/python-worker` | `m4-202606261405` | `az acr build` | Tag listed in ACR and pod image field |
| node-web | Node 24 | `acrmhb4weu001.azurecr.io/node-web` | `m4-202606261405` | `az acr build` | Tag listed in ACR and pod image field |

## GitOps config

| Item | Value |
| --- | --- |
| Flux namespace | `flux-system` |
| Git source | `flux-system` |
| App-of-apps path | `gitops/clusters/microhack` |
| Branch | `main` |
| Latest reconciled revision | `main@sha1:8f4a2c9d6e1b3a7c2d0e5f6a9b1c3d4e5f607182` |
| Ready Kustomizations | `platform-ingress`, `platform-observability`, `apps-dev`, `apps-prod` |
| Not Ready Kustomizations | None |

## Observability

| Capability | Delivered state | Evidence |
| --- | --- | --- |
| Container Insights | Enabled and connected to `law-mh-b4-weu-001` | Recent container inventory visible |
| Managed Prometheus | Enabled through Azure Monitor workspace integration | `ama-metrics` pods Running |
| Grafana | `grafana-mh-b4-weu-001` linked to metrics workspace | Dashboard opens with AKS node and pod panels |
| Application telemetry | OpenTelemetry exported from all three services | Recent traces and metrics observed |
| Diagnostic settings | AKS control plane and ACR diagnostics enabled | Diagnostic setting list from Azure MCP |

## Validation

| Check | Result | Evidence |
| --- | --- | --- |
| Flux sources Ready | Pass | `flux get sources git -A` shows Ready True |
| Flux Kustomizations Ready | Pass | All app-of-apps Kustomizations show Ready True |
| Pods Running | Pass | `kubectl get pods -n apps` shows all replicas Running |
| Workload Identity annotations present | Pass | Service accounts include `azure.workload.identity/client-id` |
| Ingress responds | Pass | `curl --fail https://shop.mh-b4.contoso.example/health` returned 200 |
| Telemetry flowing | Pass | Container Insights shows data inside the last 10 minutes |

## Diagrams

The evidence pack includes the completed architecture diagram and the logical, physical, and sequence diagrams from `diagrams-example.md`.

## Deviations and decisions

| Decision or deviation | Reason | Impact | Owner |
| --- | --- | --- | --- |
| Used Bicep track for trainer demo | Primary implementation path for the microhack | Terraform parity discussed but not executed live | Trainer |
| Used dated image tag instead of commit SHA | Classroom branch had multiple learner commits | Evidence remains traceable through ACR build timestamp | Delivery lead |

## Open follow-up items

| Item | Priority | Owner | Target date |
| --- | --- | --- | --- |
| Promote prod overlay through reviewed pull request | Medium | Platform team | 2026-06-27 |
| Add HPA to `node-web` after M5 performance test | Medium | Application team | 2026-06-27 |
