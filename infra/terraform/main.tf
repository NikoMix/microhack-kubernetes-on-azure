resource "random_string" "unique" {
  length  = 6
  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.tags
}

module "aks_identity" {
  #checkov:skip=CKV_TF_1:Terraform Registry AVM modules are pinned by explicit version per the MicroHack parity contract.
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = "0.5.3"

  name                = local.aks_identity_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
  enable_telemetry    = var.enable_telemetry
}

resource "azurerm_role_assignment" "aks_vnet_network_contributor" {
  scope                            = module.vnet.resource_id
  role_definition_id               = "${data.azurerm_subscription.current.id}/providers/Microsoft.Authorization/roleDefinitions/4d97b98b-1d4f-4787-a291-c67834d212e7"
  principal_id                     = module.aks_identity.principal_id
  principal_type                   = "ServicePrincipal"
  description                      = "Allow AKS control-plane identity to manage VNet resources."
  skip_service_principal_aad_check = true
}

data "azurerm_subscription" "current" {}

