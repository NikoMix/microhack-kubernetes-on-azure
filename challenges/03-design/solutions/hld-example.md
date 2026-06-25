# AKS secure-baseline high-level design example

This trainer-only example demonstrates the expected depth for B.3.1. It uses realistic placeholder values and stays aligned to the `infra/` and `apps/` contracts.

## Document control

| Item | Value |
| --- | --- |
| Customer | Contoso Module B MicroHack |
| Environment | Training secure baseline |
| Region | `westeurope` |
| Subscription | `<subscription-id>` |
| Resource group | `<resource-group>` |
| AKS cluster | `<cluster-name>` |
| ACR | `<acr-login-server>` |
| Key Vault | `<key-vault-name>` |

## Executive summary

The design deploys the WS2 polyglot workload to an AKS secure-baseline landing zone in West Europe. The solution uses a hub-and-spoke network, Microsoft Entra ID authentication, Azure RBAC, Workload Identity, Azure CNI Overlay, controlled ingress, Azure Firewall egress, Defender for Containers, Azure Policy for AKS, Key Vault CSI Secret Store, Container Insights, Managed Prometheus, Grafana, and budget and tagging controls. The primary trade-off is adopting managed platform controls first while keeping a private-cluster and App Gateway for Containers hardening path available.

## Requirements and constraints

- Host `node-web`, `dotnet-api`, and `python-worker` on AKS with non-root images and health endpoints.
- Keep customer data and operational telemetry in West Europe unless explicitly approved.
- Use the `infra/` secure-baseline outputs rather than hard-coded names.
- Prefer managed Azure services for identity, policy, vulnerability management, observability, and backup.
- Support both Bicep and Terraform AVM deployment paths from the contract.

## 1. IAM/RBAC with Microsoft Entra ID

Cluster authentication uses Microsoft Entra ID integrated with AKS. Azure RBAC controls cluster management operations, with separate groups for platform administrators, application operators, security readers, and read-only auditors. Human users receive least-privilege assignments such as Azure Kubernetes Service Cluster User Role plus scoped Kubernetes permissions. Workloads use Workload Identity through the cluster OIDC issuer `<oidc-issuer>` and federated credentials on managed identities. No application uses static Azure credentials.

## 2. Network architecture

The landing zone uses a hub-and-spoke topology. The hub contains Azure Firewall, DNS forwarding or Private DNS Resolver, and shared operations services. The AKS spoke contains the cluster subnet, ingress subnet, and private endpoint subnet. Azure CNI Overlay reduces VNet IP consumption while preserving Azure-native routing for nodes. Ingress is App Gateway for Containers for the preferred design, with managed NGINX acceptable for simpler cohorts. Egress uses UDRs to Azure Firewall, where approved Microsoft and workload dependencies are allowed. DNS resolution uses hub forwarding plus private DNS zones for private endpoints.

## 3. Security

Microsoft Defender for Containers is enabled for vulnerability assessment, Kubernetes threat detection, and control-plane recommendations. Azure Policy for AKS and Deployment Safeguards enforce baseline controls such as non-root containers, allowed registries, resource requirements, and restricted privilege escalation. Security findings are triaged by severity and converted into backlog items. The design avoids secrets in images and requires TLS for ingress.

## 4. Governance and cost

All resources carry tags for `workload`, `environment`, `owner`, `costCenter`, and `dataClassification`. Budgets alert the platform owner and trainer team when spend crosses agreed thresholds. Diagnostic settings send control-plane and platform logs to Log Analytics with retention sized for training evidence. Policy assignments guard approved regions, required tags, secure transfer, and AKS baseline controls.

## 5. Backup and business continuity

AKS control plane and etcd are managed by Azure, so the customer does not back up etcd directly. The design protects Kubernetes objects and persistent volumes with Azure Backup for AKS. Velero remains an option when cross-cluster migration or plugin-level portability is required. Stateless workloads are redeployed through GitOps from source. Stateful data must have service-native backup, restore testing, and recovery objectives recorded before production.

## 6. Regulatory compliance

The design uses West Europe for AKS, ACR, Key Vault, Log Analytics, and monitoring services to support data residency. Azure Policy initiatives provide evidence for allowed locations, Defender enablement, diagnostic settings, and AKS guardrails. CIS and AKS benchmark alignment is addressed through restricted pod security settings, least privilege, network controls, vulnerability scanning, and audit logging.

## 7. Cluster RBAC

Namespaces separate platform components from `node-web`, `dotnet-api`, `python-worker`, and shared ingress. Kubernetes Roles grant application teams namespace-scoped deploy, view, or support permissions. ClusterRoles are limited to platform operations and audited break-glass scenarios. RoleBindings map Entra-backed groups to Kubernetes permissions, while cluster-admin access is restricted and reviewed.

## 8. Continuous image vulnerability scanning

Images are stored in `<acr-login-server>` and scanned through Defender for Containers. Critical vulnerabilities block deployment through admission or GitOps policy before production promotion. High findings require an owner and remediation date. Image pull permissions use managed identity, and only approved registries are allowed by policy.

## 9. Resource requests, limits, namespaces, ResourceQuotas, and LimitRanges

Each application namespace has default CPU and memory requests, upper limits, ResourceQuotas, and LimitRanges. `node-web` receives higher availability and ingress capacity; `dotnet-api` receives API request capacity; `python-worker` receives worker concurrency capacity. Quotas protect the cluster from noisy neighbours and support autoscaler decisions. Pod disruption budgets protect rolling upgrades for user-facing services.

## 10. Monitoring and alerting

Container Insights sends inventory, performance, and log data to Log Analytics. Managed Prometheus scrapes Kubernetes and application metrics, and Azure Managed Grafana provides dashboards. Alerts cover node readiness, pod crash loops, high restart count, unschedulable pods, ingress errors, firewall-denied traffic spikes, persistent volume issues, and application health. Alerts have owners and expected response paths for M6 runbooks.

## 11. Liveness, readiness, and startup probes

`dotnet-api` exposes `/health` for liveness and readiness. `node-web` uses its status endpoint and downstream readiness checks to avoid receiving traffic before the API is reachable. `python-worker` exposes an HTTP health or metrics endpoint suitable for liveness and startup checks. Startup probes protect slower initialisation, readiness probes protect rolling updates, and liveness probes restart stuck containers.

## 12. Secrets in Key Vault

Application secrets live in `<key-vault-name>` and are mounted through the Secrets Store CSI Driver. Workload Identity authorises each service to only the required secrets. Rotation is enabled where supported, and pods are restarted or refreshed through the documented rotation mechanism. Secrets are excluded from container images, Helm values committed to source, logs, and environment defaults.

## 13. Cluster design document

The cluster has a zonal system node pool for platform add-ons and a zonal user node pool for application workloads. Autoscaling is enabled with conservative minimum capacity to keep core workloads available. The design uses AKS planned maintenance windows, controlled Kubernetes version upgrades, node image upgrade cadence, and surge settings that preserve availability. Add-ons include Azure Policy, Defender, Workload Identity, Key Vault CSI, Container Insights, Managed Prometheus, and Grafana integration.

## 14. Network design document

The network design records hub and spoke address spaces, AKS subnet, ingress subnet, private endpoint subnet, Pod CIDR, Service CIDR, DNS service IP, route tables, and NSGs. Ingress terminates at App Gateway for Containers or managed NGINX and routes to `node-web` before internal service calls. Egress follows UDRs to Azure Firewall and only approved destinations are allowed. Private DNS zones support Key Vault, ACR, and any private endpoint dependencies.

## Architecture diagram

Use `solutions/architecture-diagram-example.md` as the completed diagram. It shows hub/spoke peering, AKS node pools, application namespaces, ACR, Key Vault, Defender, Azure Policy, Azure Monitor, Managed Prometheus, Grafana, Backup, ingress, egress, Entra ID, and GitOps flow.

## Risks and decisions

| ID | Risk or decision | Impact | Mitigation or owner |
| --- | --- | --- | --- |
| D-001 | App Gateway for Containers is preferred, managed NGINX is acceptable for class fallback. | Learners may produce different ingress designs. | Require clear rationale and equivalent health, TLS, and routing controls. |
| D-002 | Private cluster is a stretch variant. | Public API server exposure may be acceptable only for training. | Document allowed source ranges or private option before production. |
| R-001 | Stateful data ownership is not fully known from M2. | Backup design may be incomplete. | Add P1 backlog item to confirm persistent volumes and external data stores. |

## References

- [AKS baseline architecture](https://learn.microsoft.com/azure/architecture/reference-architectures/containers/aks/baseline-aks)
- [Well-Architected Framework service guide for AKS](https://learn.microsoft.com/azure/well-architected/service-guides/azure-kubernetes-service)
- [Microsoft Defender for Containers](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-containers-introduction)
- [Azure Policy for AKS](https://learn.microsoft.com/azure/aks/use-azure-policy)
- [Secrets Store CSI Driver for AKS](https://learn.microsoft.com/azure/aks/csi-secrets-store-driver)
