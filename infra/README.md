# `infra/` — AKS Secure Baseline (Bicep + Terraform, AVM‑first)

Infrastructure‑as‑Code for the MicroHack landing zone, kept in **parity** across two tracks.

## Tracks
- [`bicep/`](bicep/) — Azure Verified Modules (Bicep) — primary lab track.
- [`terraform/`](terraform/) — Azure Verified Modules (Terraform) — parity track.

## Target architecture (West Europe)
AKS **secure baseline** suitable for teaching Module B (B.3.1 / B.4.1):

- AKS cluster: system + user node pools, **Microsoft Entra ID + Azure RBAC**, **Workload
  Identity**, API server VNet integration / private option, **Azure CNI Overlay**.
- **Azure Container Registry** with image pull via managed identity; image integrity.
- Networking: hub/spoke‑ready VNet, subnets, **Azure Firewall** egress option, ingress via
  **App Gateway for Containers** / managed NGINX.
- Security: **Microsoft Defender for Containers**, **Azure Policy for AKS** + Deployment
  Safeguards, **Key Vault** + CSI Secret Store.
- Observability: **Azure Monitor / Container Insights**, **Managed Prometheus + Grafana**.
- Governance: Log Analytics, diagnostic settings, budgets/cost notes.

## Conventions
- Parameterised for region (default `westeurope`), naming, and cost guardrails.
- `main` deploys the full baseline; feature toggles for optional add‑ons.
- Validated in CI: `az bicep build`, `terraform validate`, **PSRule for Azure**, **tflint**,
  **checkov**. No hard‑coded secrets.

> Owned by workstream **WS1 (Infra)**.
