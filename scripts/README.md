# `scripts/` — Lab automation

Cross‑platform helpers (PowerShell 7 + Bash) for the lab day.

| Script | Purpose |
|---|---|
| `preflight` | Check Azure login, subscription, **region/quota** (West Europe), required CLIs |
| `deploy` | Deploy the chosen IaC track (Bicep or Terraform) end‑to‑end |
| `bootstrap-gitops` | Install Flux v2 / connect the GitOps repo |
| `cost-report` | Summarise estimated/actual spend for the lab resources |
| `teardown` | **Delete all billable resources** (run at end of day) |

## Conventions
- Idempotent and re‑runnable; clear logging; non‑zero exit on failure.
- No secrets in source; read from environment / Azure CLI context.
- PowerShell scripts pass **PSScriptAnalyzer**; Bash passes **shellcheck**.

> Owned by workstream **WS1 (Infra)**.
