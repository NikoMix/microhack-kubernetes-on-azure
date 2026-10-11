output "resource_group_name" {
  description = "Resource group name."
  value       = azurerm_resource_group.this.name
}

output "aks_cluster_name" {
  description = "AKS cluster name."
  value       = module.aks.name
}

output "aks_cluster_resource_id" {
  description = "AKS cluster resource ID."
  value       = module.aks.resource_id
}

output "aks_node_resource_group" {
  description = "AKS managed node resource group name."
  value       = module.aks.node_resource_group_name
}

output "aks_control_plane_fqdn" {
  description = "AKS control plane FQDN."
  value       = coalesce(module.aks.fqdn, module.aks.private_fqdn, "")
}

output "aks_oidc_issuer_url" {
  description = "AKS OIDC issuer URL."
  value       = coalesce(module.aks.oidc_issuer_profile_issuer_url, "")
}

output "aks_kubelet_identity_object_id" {
  description = "AKS kubelet identity object ID."
  value       = coalesce(module.aks.kubelet_identity.objectId, "")
}

output "aks_kubelet_identity_client_id" {
  description = "AKS kubelet identity client ID."
  value       = coalesce(module.aks.kubelet_identity.clientId, "")
}

output "aks_kubelet_identity_resource_id" {
  description = "AKS kubelet identity resource ID."
  value       = coalesce(module.aks.kubelet_identity.resourceId, "")
}

output "aks_cluster_principal_id" {
  description = "AKS control-plane user-assigned identity principal ID."
  value       = module.aks_identity.principal_id
}

output "acr_name" {
  description = "Azure Container Registry name."
  value       = module.acr.name
}

output "acr_login_server" {
  description = "Azure Container Registry login server."
  value       = module.acr.resource.login_server
}

output "acr_resource_id" {
  description = "Azure Container Registry resource ID."
  value       = module.acr.resource_id
}

output "key_vault_name" {
  description = "Key Vault name."
  value       = module.key_vault.name
}

output "key_vault_uri" {
  description = "Key Vault URI."
  value       = module.key_vault.uri
}

output "key_vault_resource_id" {
  description = "Key Vault resource ID."
  value       = module.key_vault.resource_id
}

output "log_analytics_workspace_resource_id" {
  description = "Log Analytics workspace resource ID."
  value       = module.log_analytics.resource_id
}

output "azure_monitor_workspace_resource_id" {
  description = "Azure Monitor Workspace resource ID."
  value       = var.enable_managed_prometheus ? azurerm_monitor_workspace.prometheus[0].id : ""
}

output "grafana_resource_id" {
  description = "Managed Grafana resource ID."
  value       = var.enable_managed_grafana ? azurerm_dashboard_grafana.this[0].id : ""
}

output "grafana_endpoint" {
  description = "Managed Grafana endpoint URL."
  value       = var.enable_managed_grafana ? azurerm_dashboard_grafana.this[0].endpoint : ""
}

output "vnet_resource_id" {
  description = "VNet resource ID."
  value       = module.vnet.resource_id
}

output "system_subnet_resource_id" {
  description = "AKS node subnet resource ID."
  value       = local.node_subnet_resource_id
}

output "ingress_type" {
  description = "Ingress implementation selected."
  value       = var.ingress_type
}

output "get_credentials_command" {
  description = "Azure CLI command to retrieve AKS credentials."
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.this.name} --name ${module.aks.name} --overwrite-existing"
}

