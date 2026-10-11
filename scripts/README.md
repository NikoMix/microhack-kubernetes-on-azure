# `scripts/` — Lab automation

Cross-platform helpers (PowerShell 7 primary + Bash mirror) for WS1 infrastructure lab automation. Every pair is designed to be idempotent, fail fast with a non-zero exit code on hard failures, and avoid hardcoded secrets.

| Script | Purpose |
|---|---|
| `preflight` | Check Azure login, subscription, **region/quota** (West Europe), required CLIs |
| `deploy` | Deploy the chosen IaC track (Bicep or Terraform) end-to-end |
| `bootstrap-gitops` | Install Flux v2 / connect the GitOps repo |
| `cost-report` | Summarise estimated/actual spend for the lab resources |
| `teardown` | **Delete all billable resources** (run at end of day) |

## Prerequisites

- PowerShell 7+ for `.ps1` scripts, or Bash 4+ for `.sh` scripts.
- Azure CLI authenticated with `az login`.
- `kubectl` and `helm` on `PATH`.
- Bicep track: `az bicep` available through Azure CLI.
- Terraform track: `terraform` on `PATH`.
- Optional: `gh` and `flux` CLIs.

Default values: region `westeurope`, workload name `mhaks`, environment `dev`, Flux branch `main`, GitOps path `./gitops/clusters/microhack`.

## Typical lab-day flow

### 1. Preflight

PowerShell:

```powershell
./scripts/preflight.ps1 -Location westeurope -Track bicep
./scripts/preflight.ps1 -Subscription <subscription-id> -Track terraform
```

Bash:

```bash
./scripts/preflight.sh --location westeurope --track bicep
./scripts/preflight.sh --subscription <subscription-id> --track terraform
```

Parameters: `Subscription`, `Location`, `Track`.

### 2. Deploy or preview infrastructure

PowerShell:

```powershell
./scripts/deploy.ps1 -Track bicep -Action whatif
./scripts/deploy.ps1 -Track bicep -Action deploy -Environment dev -WorkloadName mhaks -Force
./scripts/deploy.ps1 -Track terraform -Action deploy -ResourceGroupName rg-mhaks-dev -Force
```

Bash:

```bash
./scripts/deploy.sh --track bicep --action whatif
./scripts/deploy.sh --track bicep --action deploy --environment dev --workload-name mhaks --force
./scripts/deploy.sh --track terraform --action deploy --resource-group-name rg-mhaks-dev --force
```

Parameters: `Track` (`bicep|terraform`), `Action` (`whatif|deploy`), `Location`, `Environment`, `WorkloadName`, `ResourceGroupName`, `Subscription`, `Force`.

### 3. Bootstrap GitOps

PowerShell:

```powershell
./scripts/bootstrap-gitops.ps1 -ResourceGroupName rg-mhaks-dev -ClusterName aks-mhaks-dev
./scripts/bootstrap-gitops.ps1 -ResourceGroupName rg-mhaks-dev -ClusterName aks-mhaks-dev -GitOpsRepoUrl https://github.com/org/repo.git -Force
```

Bash:

```bash
./scripts/bootstrap-gitops.sh --resource-group-name rg-mhaks-dev --cluster-name aks-mhaks-dev
./scripts/bootstrap-gitops.sh --resource-group-name rg-mhaks-dev --cluster-name aks-mhaks-dev --gitops-repo-url https://github.com/org/repo.git --force
```

Parameters: `ResourceGroupName`, `ClusterName`, `Subscription`, `GitOpsRepoUrl`, `Branch`, `GitOpsPath`, `Force`.

### 4. Cost report

PowerShell:

```powershell
./scripts/cost-report.ps1 -ResourceGroupName rg-mhaks-dev
./scripts/cost-report.ps1 -ResourceGroupName rg-mhaks-dev -Subscription <subscription-id>
```

Bash:

```bash
./scripts/cost-report.sh --resource-group-name rg-mhaks-dev
./scripts/cost-report.sh --resource-group-name rg-mhaks-dev --subscription <subscription-id>
```

Parameters: `ResourceGroupName`, `Subscription`.

### 5. Teardown

PowerShell:

```powershell
./scripts/teardown.ps1 -Track bicep -ResourceGroupName rg-mhaks-dev -Force
./scripts/teardown.ps1 -Track bicep -ResourceGroupName rg-mhaks-dev -Force -Wait
./scripts/teardown.ps1 -Track terraform -Force
```

Bash:

```bash
./scripts/teardown.sh --track bicep --resource-group-name rg-mhaks-dev --force
./scripts/teardown.sh --track bicep --resource-group-name rg-mhaks-dev --force --wait
./scripts/teardown.sh --track terraform --force
```

Parameters: `Track`, `ResourceGroupName`, `Subscription`, `Force`, `Wait`.

## Conventions

- Idempotent and re-runnable; clear timestamped logging; non-zero exit on failure.
- No secrets in source; use Azure CLI context, parameters, and environment variables.
- Use `-h`, `--help`, or PowerShell `-?` for usage.
- PowerShell scripts pass PSScriptAnalyzer; Bash scripts pass shellcheck.
- Soft-deleted Key Vaults with purge protection remain until their retention window expires and cannot be purged early.

> Owned by workstream **WS1 (Infra)**.
