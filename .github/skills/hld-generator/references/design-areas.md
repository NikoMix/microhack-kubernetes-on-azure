# AKS design areas (B.3.1 reference)

Comprehensive design areas for an AKS landing-zone / secure-baseline HLD. Each area lists the
decisions to make and the Azure feature / AVM module that implements it. Default region
`westeurope`.

## Reference architecture routing

| Customer signal | Route to |
|---|---|
| First production AKS, single region, baseline security | **AKS baseline** |
| Regulated (PCI / HIPAA / FedRAMP), private cluster, strict egress | **AKS secure baseline** |
| Multi-region active/active or active/passive | **AKS multi-region** + Front Door + App Gateway for Containers |
| Enterprise ALZ hub/spoke + Bastion + Firewall | **AKS landing-zone accelerator** |
| API / job workload without cluster admin | **Azure Container Apps** |
| Edge / sovereign / disconnected | **AKS on Azure Local** / **AKS enabled by Azure Arc** |

## 1. Identity & access

- Cluster authentication: **Microsoft Entra ID** integration; disable local accounts.
- Authorization: **Azure RBAC for Kubernetes** (Azure role assignments) over namespaces.
- Workload-to-Azure: **Microsoft Entra Workload Identity** (federated) — no static secrets.
- Admin model: just-in-time, PIM-eligible cluster-admin; break-glass account documented.

## 2. Network topology & connectivity

- Data plane: **Azure CNI Overlay** (pod CIDR overlay), or CNI + Cilium for network policy.
- Cluster exposure: **private cluster** / API server VNet integration; Private DNS / Private Link.
- Topology: hub/spoke-ready VNet, subnets per pool, peering to ALZ hub.
- Egress: **Azure Firewall** with FQDN allow-list; default-deny outbound.
- Ingress: **Application Gateway for Containers** or managed NGINX; TLS via Key Vault certs.

## 3. Cluster & node pools

- **System** pool (CriticalAddonsOnly taint) + **user** pool(s); multi-AZ spread.
- Sizing & SKUs; ephemeral OS disks; spot pool for batch (optional).
- Scaling: cluster autoscaler / **node autoprovisioning** (Karpenter-style).
- Upgrades: release/upgrade **channel**, **planned maintenance windows**, **surge** settings.

## 4. Namespaces & multi-tenancy

- Namespace-per-app or per-team; labels/annotations standard.
- **ResourceQuota** + **LimitRange** per namespace; **NetworkPolicy** default-deny.

## 5. Workload scheduling & resilience

- Liveness / readiness / startup **probes**; graceful shutdown.
- **PodDisruptionBudget**; requests & limits; topology spread constraints.
- Autoscale: **HPA** (metrics) and **KEDA** (event-driven).

## 6. Security & compliance

- **Microsoft Defender for Containers** (posture + runtime).
- **Azure Policy for AKS** (Gatekeeper) + **Deployment Safeguards**; restricted Pod Security.
- Supply chain: image integrity, signing (Notation / Notary v2), **SBOM** (Trivy / Syft).

## 7. Secrets management

- **Key Vault** + **CSI Secret Store** driver; secret rotation; no secrets in images/manifests.

## 8. Storage & data

- CSI: Azure Disk (RWO), Azure Files (RWX), Blob (object); StorageClasses & reclaim policy.
- **Backup for AKS** (or Velero) schedule; data residency.

## 9. Observability & monitoring

- **Container Insights** (Log Analytics) + **Managed Prometheus** + **Managed Grafana**.
- Diagnostic settings on cluster/registry/Key Vault; alert rules; **SLOs** defined.

## 10. Governance & cost

- Azure Policy initiatives; resource **tags**; **budgets** + cost alerts; log retention.

## 11. Business continuity / DR

- Multi-AZ baseline; multi-region option (paired regions + Front Door); **DR drill** cadence.

## 12. CI/CD & GitOps

- **Flux v2** (app-of-apps) reconciling from `gitops/`; IaC via **AVM** (Bicep/Terraform).
- Golden cluster baseline; environment promotion via overlays.

## 13. Container registry & supply chain

- **Azure Container Registry**; **managed-identity** image pull; image integrity; geo-replication
  (multi-region).

## 14. Platform lifecycle & currency

- Kubernetes version **support policy** (N-2); node-image auto-upgrade; deprecation tracking.

## Sources (fetch current detail)

- `microsoft_docs_fetch(url="https://learn.microsoft.com/azure/architecture/reference-architectures/containers/aks/baseline-aks")`
- `microsoft_docs_search(query="AKS landing zone accelerator design areas")`
- `microsoft_docs_search(query="AKS secure baseline architecture")`
