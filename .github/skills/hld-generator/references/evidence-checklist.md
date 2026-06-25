# B.3.1 Solution Design — evidence checklist

Audit control **B.3.1 — Solution Design** (checklist V2.5.1). The design must address the **full
set of AKS design areas** — a missing area fails the control.

## Audit requirement

- **3 unique customers**, **2 artifacts each** (e.g. HLD + architecture diagram, or HLD + LLD).
- Design covers all AKS design areas listed below with explicit decisions and rationale.

## Design-area coverage (every box must be ticked or justified N/A)

- [ ] Identity & access — Entra ID, **Azure RBAC for Kubernetes**, **Workload Identity**, admin model.
- [ ] Network topology & connectivity — **Azure CNI Overlay**, private cluster, hub/spoke, DNS,
      Private Link, egress (**Azure Firewall**), ingress (**App Gateway for Containers** / NGINX).
- [ ] Cluster & node pools — system + user pools, **multi-AZ**, sizing, autoscaling / node
      autoprovisioning, upgrade channel, **maintenance windows**, surge upgrade.
- [ ] Namespaces & multi-tenancy — namespace strategy, ResourceQuotas, **NetworkPolicy**.
- [ ] Workload scheduling & resilience — probes, **PDB**, requests/limits, topology spread,
      **HPA / KEDA**.
- [ ] Security & compliance — **Defender for Containers**, **Azure Policy for AKS** + **Deployment
      Safeguards**, Pod Security, image integrity / signing, SBOM.
- [ ] Secrets management — **Key Vault** + **CSI Secret Store**, rotation.
- [ ] Storage & data — CSI drivers (disk/file/blob), **Backup for AKS**, residency.
- [ ] Observability & monitoring — **Container Insights**, **Managed Prometheus + Grafana**, Log
      Analytics, diagnostic settings, alerts / SLOs.
- [ ] Governance & cost — Azure Policy, budgets, tagging, retention.
- [ ] Business continuity / DR — multi-AZ, multi-region option, DR drill cadence.
- [ ] CI/CD & GitOps — **Flux v2**, IaC / **AVM**, golden baseline.
- [ ] Container registry & supply chain — **ACR**, managed-identity pull, image integrity.
- [ ] Platform lifecycle & currency — K8s version support policy, node-image upgrades.

## Quality gates

- [ ] Architecture diagram exported as evidence.
- [ ] Decisions register (ADR-style) included.
- [ ] Traceability: every B.2.1 remediation item maps to a design area.
- [ ] Anonymised; filed as `B3.1_<DocType>_<Customer>_v<N>.<ext>` in the Evidence Index.

## Cross-references

- Input: `workload-assessment` (B.2.1). Output feeds `war-runner` (B.3.2) and `as-built` (B.4.1).
