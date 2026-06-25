# B.4.1 Delivery / B.5.2 — as-built evidence checklist

Audit controls **B.4.1 — Delivery** and **B.5.2 — Post-deployment Documentation**
(checklist V2.5.1).

## Audit requirement

- **B.4.1:** 3 customers; **≥2 of** {SOW, design doc, project plan, architecture diagrams,
  **as-built**}. Delivery on **AKS** (or ARO).
- **B.5.2:** as-built forms part of the post-deployment documentation set.

## Evidence items (per customer)

- [ ] Cluster as-built: K8s version, node pools, AZs, CNI, private/public, SLA tier.
- [ ] Networking: VNet/subnets, private cluster, Azure Firewall egress, ingress (App Gateway for
      Containers / NGINX), DNS/Private Link.
- [ ] Identity: Entra integration, Azure RBAC for Kubernetes, **Workload Identity** federations.
- [ ] Platform services: ACR, Key Vault + CSI, Defender for Containers, Azure Policy, Monitor /
      Managed Prometheus / Grafana.
- [ ] GitOps state: Flux sources/Kustomizations/HelmReleases + revisions from `gitops/`.
- [ ] Version inventory (platform + apps + AVM modules) for currency baseline.
- [ ] Architecture diagram exported.
- [ ] **Delta vs. B.3.1 HLD** with reasons and (where relevant) customer acknowledgement.
- [ ] Anonymised; filed as `B4.1_AsBuilt_<Customer>_v<N>.pdf` in the Evidence Index.

## Cross-references

- Input: `hld-generator` (B.3.1). Pairs with `runbook` (B.5.2). Feeds `test-plan` (B.5.1).
- Track delivery tasks as GitHub Issues labelled `module:b4.1`.
