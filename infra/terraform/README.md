# WS1 (Infra) — AKS secure-baseline Terraform

This folder is the Terraform implementation of the MicroHack AKS secure-baseline landing zone. It mirrors the Bicep track root variables, naming, and output contract.

## What it deploys

- Resource group and deterministic baseline naming.
- Spoke VNet with AKS node, ingress, private endpoint, optional API server, and optional Azure Firewall subnets.
- AKS with Microsoft Entra ID, Azure RBAC, OIDC issuer, Workload Identity, Azure CNI Overlay, optional managed NGINX routing, Container Insights, Managed Prometheus, Azure Policy, Key Vault CSI, image cleaner, and cluster-level Defender.
- ACR Premium by default, managed-identity pull, anonymous/admin disabled.
- Key Vault with RBAC authorization, purge protection, soft delete, optional private endpoint.
- Log Analytics, Azure Monitor Workspace, DCE/DCR/DCRA, and optional Managed Grafana with role assignments.
- Optional resource-group budget when alert emails are supplied.

## Validate locally

From the repo root on Windows PowerShell (ensure `terraform`, `tflint`, and `checkov` are on `PATH`):

```powershell
terraform -chdir=infra\terraform fmt -recursive
terraform -chdir=infra\terraform fmt -check -recursive
terraform -chdir=infra\terraform init -backend=false
terraform -chdir=infra\terraform validate
tflint --chdir=infra\terraform --init
tflint --chdir=infra\terraform
python -m checkov.main -d infra\terraform --compact
```

Do not run `terraform apply` for static validation.

## Deploy

Use the workshop deployment scripts once the shared pipeline/backend is ready. Uncomment `backend.tf` only after the remote state storage account is provisioned.

## Outputs contract

The following snake_case outputs are preserved for WS2/WS3/GitOps: `resource_group_name`, `aks_cluster_name`, `aks_cluster_resource_id`, `aks_node_resource_group`, `aks_control_plane_fqdn`, `aks_oidc_issuer_url`, `aks_kubelet_identity_object_id`, `aks_kubelet_identity_client_id`, `aks_kubelet_identity_resource_id`, `aks_cluster_principal_id`, `acr_name`, `acr_login_server`, `acr_resource_id`, `key_vault_name`, `key_vault_uri`, `key_vault_resource_id`, `log_analytics_workspace_resource_id`, `azure_monitor_workspace_resource_id`, `grafana_resource_id`, `grafana_endpoint`, `vnet_resource_id`, `system_subnet_resource_id`, `ingress_type`, and `get_credentials_command`.

## Notes and assumptions

- Ingress: the lab default is `ingress_type = "none"` — the Flux GitOps stack installs **ingress-nginx** (class `nginx`) as the single controller, which the apps and cert-manager target. `managedNginx` (app-routing add-on) and `appGatewayForContainers` remain B.3.1 design-area alternatives.
- App Gateway for Containers is exposed as an `ingress_type` contract value; controller installation is expected at runtime through GitOps.
- Defender here enables only the AKS cluster-level LAW-backed profile. The subscription-level Defender for Containers plan must be enabled separately.
- Azure budgets require at least one notification target, so the budget resource is created only when `enable_budget = true` and `budget_alert_emails` is non-empty.
- Private endpoint DNS zones are expected to be managed by platform policy or added later; the AVM private endpoint inputs intentionally do not create DNS zones here.
