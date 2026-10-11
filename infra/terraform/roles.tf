resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                            = module.acr.resource_id
  role_definition_id               = "${data.azurerm_subscription.current.id}/providers/Microsoft.Authorization/roleDefinitions/7f951dda-4ed3-4680-a7ca-43fe172d538d"
  principal_id                     = module.aks.kubelet_identity.objectId
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "aks_key_vault_secrets_user" {
  count = var.enable_key_vault_csi ? 1 : 0

  scope                            = module.key_vault.resource_id
  role_definition_id               = "${data.azurerm_subscription.current.id}/providers/Microsoft.Authorization/roleDefinitions/4633458b-17de-408a-b874-0445c86b69e6"
  principal_id                     = module.aks.key_vault_secrets_provider_identity.objectId
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_monitor_data_collection_rule_association" "aks_prometheus" {
  count = var.enable_managed_prometheus ? 1 : 0

  name                    = "dcra-${local.aks_name}-prom"
  target_resource_id      = module.aks.resource_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.prometheus[0].id
  description             = "Associate AKS with the Managed Prometheus DCR."

  depends_on = [azapi_resource.user_node_pool]
}

