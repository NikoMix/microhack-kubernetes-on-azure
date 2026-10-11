# As-built template

Use this template to capture the factual delivered state for Control B.4.1.

## Document control

| Field | Value |
| --- | --- |
| Customer or cohort | `<customer-or-cohort>` |
| Prepared by | `<name>` |
| Date | `<date>` |
| Control | B.4.1 Delivery |
| Source of truth | Azure MCP, GitHub MCP, `az`, `kubectl`, and Flux output |

## Environment

| Item | Value |
| --- | --- |
| Subscription ID | `<subscription-id>` |
| Tenant ID | `<tenant-id>` |
| Region | `westeurope` |
| Resource group | `<resource-group>` |
| Deployment track | `<bicep-or-terraform>` |
| GitOps repository | `<repo-url>` |
| GitOps branch | `<branch>` |
| GitOps path | `gitops/clusters/microhack` |

## Resources deployed

| Resource type | Name | Purpose | Evidence source |
| --- | --- | --- | --- |
| AKS cluster | `<cluster-name>` | Secure workload platform | `<az-or-mcp-output>` |
| Azure Container Registry | `<acr-name>` | Container image registry | `<az-or-mcp-output>` |
| Key Vault | `<key-vault-name>` | Secrets provider for CSI Secret Store | `<az-or-mcp-output>` |
| Log Analytics workspace | `<workspace-name>` | Container Insights and diagnostics | `<az-or-mcp-output>` |
| Managed Grafana | `<grafana-name>` | Metrics dashboards | `<az-or-mcp-output>` |

## Identities

| Identity | Scope | Permission or use | Validation |
| --- | --- | --- | --- |
| AKS control plane identity | `<scope>` | Cluster resource management | `<evidence>` |
| Kubelet or node identity | ACR | `AcrPull` | `<evidence>` |
| Workload Identity service account | Application namespace | Federated access to Azure resources | `<evidence>` |
| Key Vault access identity | Key Vault | Secret retrieval through CSI | `<evidence>` |

## Network

| Area | Delivered state | Evidence |
| --- | --- | --- |
| VNet and subnets | `<hub-spoke-vnet-and-subnet-summary>` | `<evidence>` |
| Pod networking | Azure CNI Overlay | `<evidence>` |
| API server access | `<private-or-integrated-mode>` | `<evidence>` |
| Egress | Azure Firewall or approved egress path | `<evidence>` |
| Policy and Defender | Azure Policy for AKS and Defender for Containers | `<evidence>` |

## Ingress

| Item | Value |
| --- | --- |
| Ingress implementation | `<app-gateway-for-containers-or-managed-nginx>` |
| Hostname | `<ingress-host>` |
| TLS or certificate source | `<issuer-or-certificate-source>` |
| Health endpoint tested | `<url>` |
| Result | `<status-code-and-timestamp>` |

## Images and versions

| Service | Runtime | Image | Tag | Build method | Verification |
| --- | --- | --- | --- | --- | --- |
| dotnet-api | .NET 10 | `<acr-login-server>/dotnet-api` | `<tag>` | `az acr build` or Docker | `<evidence>` |
| python-worker | Python 3.14 | `<acr-login-server>/python-worker` | `<tag>` | `az acr build` or Docker | `<evidence>` |
| node-web | Node 24 | `<acr-login-server>/node-web` | `<tag>` | `az acr build` or Docker | `<evidence>` |

## GitOps config

| Item | Value |
| --- | --- |
| Flux namespace | `flux-system` |
| Git source | `<source-name>` |
| App-of-apps path | `gitops/clusters/microhack` |
| Branch | `<branch>` |
| Latest reconciled revision | `<commit-sha>` |
| Ready Kustomizations | `<names>` |
| Not Ready Kustomizations | `<names-or-none>` |

## Observability

| Capability | Delivered state | Evidence |
| --- | --- | --- |
| Container Insights | `<enabled-and-workspace>` | `<evidence>` |
| Managed Prometheus | `<enabled-or-not-applicable>` | `<evidence>` |
| Grafana | `<dashboard-link-or-name>` | `<evidence>` |
| Application telemetry | OpenTelemetry to Azure Monitor | `<evidence>` |
| Diagnostic settings | `<resources-covered>` | `<evidence>` |

## Validation

| Check | Result | Evidence |
| --- | --- | --- |
| Flux sources Ready | `<pass-or-fail>` | `<output-or-link>` |
| Flux Kustomizations Ready | `<pass-or-fail>` | `<output-or-link>` |
| Pods Running | `<pass-or-fail>` | `<output-or-link>` |
| Workload Identity annotations present | `<pass-or-fail>` | `<output-or-link>` |
| Ingress responds | `<pass-or-fail>` | `<output-or-link>` |
| Telemetry flowing | `<pass-or-fail>` | `<output-or-link>` |

## Diagrams

Attach or link the following diagrams:

- Architecture diagram.
- Logical diagram.
- Physical diagram.
- Sequence diagram.

## Deviations and decisions

| Decision or deviation | Reason | Impact | Owner |
| --- | --- | --- | --- |
| `<decision>` | `<reason>` | `<impact>` | `<owner>` |

## Open follow-up items

| Item | Priority | Owner | Target date |
| --- | --- | --- | --- |
| `<follow-up>` | `<priority>` | `<owner>` | `<date>` |
