# WAF pillars — AKS review question set (B.3.2)

Use these AKS-specific checks per pillar. Rate each RAG and tie recommendations to a feature.

## Reliability

- [ ] **Multi-AZ** node pools; control-plane SLA tier appropriate to criticality.
- [ ] **Multi-region** strategy (paired regions + Front Door + App Gateway for Containers) where
      RTO/RPO demands it.
- [ ] **PodDisruptionBudgets** for every critical Deployment; sensible replica counts.
- [ ] **Planned maintenance windows** + **surge upgrades**; node-image auto-upgrade.
- [ ] **Backup for AKS** / Velero with a tested **DR drill** cadence.
- [ ] Health probes (liveness/readiness/startup); graceful shutdown; retries/idempotency.
- [ ] Capacity: cluster autoscaler / node autoprovisioning; **KEDA** for event spikes.

## Security

- [ ] **Microsoft Entra ID** auth; **Azure RBAC for Kubernetes**; local accounts disabled.
- [ ] **Workload Identity** (federated); **no static secrets**; Key Vault + CSI for secrets.
- [ ] **Private cluster** / API server VNet integration; Private Link; default-deny egress via
      **Azure Firewall**.
- [ ] **Defender for Containers** (posture + runtime) enabled and triaged.
- [ ] **Azure Policy for AKS** + **Deployment Safeguards**; restricted Pod Security; NetworkPolicy.
- [ ] Supply chain: image integrity, signing (Notation), **SBOM**, registry managed-identity pull.

## Operational Excellence (swap-in)

- [ ] **GitOps** (Flux v2) reconciling from `gitops/`; drift detection.
- [ ] IaC via **AVM** (Bicep/Terraform); golden baseline; environment promotion via overlays.
- [ ] Observability: Container Insights + Managed Prometheus + Grafana; **SLOs** + alerts.
- [ ] Documented runbooks (cluster lifecycle, upgrade, triage); on-call defined.
- [ ] CI/CD with security gates (CodeQL, Trivy, IaC scan) — see `.github/workflows/`.

## Performance Efficiency (secondary)

- [ ] Right-sized requests/limits; VPA recommendations; appropriate SKUs / spot for batch.
- [ ] HPA tuned; topology spread; data path latency.

## Cost Optimization (secondary)

- [ ] Budgets + cost alerts; autoscaling to zero where possible; spot pools; reservations.
- [ ] Log Analytics retention right-sized; Managed Prometheus metric volume reviewed.

## Source

- `microsoft_docs_fetch(url="https://learn.microsoft.com/azure/well-architected/service-guides/azure-kubernetes-service")`
