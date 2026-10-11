module "acr" {
  #checkov:skip=CKV_TF_1:Terraform Registry AVM modules are pinned by explicit version per the MicroHack parity contract.
  source  = "Azure/avm-res-containerregistry-registry/azurerm"
  version = "0.8.0"

  name                          = local.acr_name
  location                      = azurerm_resource_group.this.location
  resource_group_name           = azurerm_resource_group.this.name
  sku                           = var.acr_sku
  admin_enabled                 = false
  anonymous_pull_enabled        = false
  data_endpoint_enabled         = var.acr_sku == "Premium"
  public_network_access_enabled = !var.enable_private_endpoints
  export_policy_enabled         = !var.enable_private_endpoints
  network_rule_bypass_option    = "None"
  zone_redundancy_enabled       = var.acr_sku == "Premium"
  tags                          = local.tags
  enable_telemetry              = var.enable_telemetry
  diagnostic_settings           = local.diagnostic_settings

  private_endpoints = var.enable_private_endpoints ? {
    registry = {
      name               = "pep-${local.acr_name}"
      subnet_resource_id = local.private_endpoint_subnet_resource_id
      tags               = local.tags
    }
  } : {}
}

