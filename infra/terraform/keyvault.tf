data "azurerm_client_config" "current" {}

module "key_vault" {
  #checkov:skip=CKV_TF_1:Terraform Registry AVM modules are pinned by explicit version per the MicroHack parity contract.
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.10.2"

  name                           = local.key_vault_name
  location                       = azurerm_resource_group.this.location
  resource_group_name            = azurerm_resource_group.this.name
  tenant_id                      = data.azurerm_client_config.current.tenant_id
  sku_name                       = "standard"
  legacy_access_policies_enabled = false
  purge_protection_enabled       = true
  soft_delete_retention_days     = 90
  public_network_access_enabled  = !var.enable_private_endpoints
  network_acls = var.enable_private_endpoints ? {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  } : null
  tags                = local.tags
  enable_telemetry    = var.enable_telemetry
  diagnostic_settings = local.diagnostic_settings

  private_endpoints = var.enable_private_endpoints ? {
    vault = {
      name               = "pep-${local.key_vault_name}"
      subnet_resource_id = local.private_endpoint_subnet_resource_id
      tags               = local.tags
    }
  } : {}
}

