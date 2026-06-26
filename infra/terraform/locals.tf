locals {
  loc_short_map = {
    westeurope         = "weu"
    northeurope        = "neu"
    eastus             = "eus"
    eastus2            = "eus2"
    westus             = "wus"
    westus2            = "wus2"
    westus3            = "wus3"
    centralus          = "cus"
    uksouth            = "uks"
    ukwest             = "ukw"
    francecentral      = "frc"
    germanywestcentral = "gwc"
    switzerlandnorth   = "szn"
    swedencentral      = "sdc"
    norwayeast         = "nwe"
  }

  location_lower      = lower(var.location)
  loc_short           = lookup(local.loc_short_map, local.location_lower, substr(local.location_lower, 0, 3))
  workload_token      = lower(var.workload_name)
  environment_token   = lower(var.environment)
  workload_compact    = replace(local.workload_token, "-", "")
  environment_compact = replace(local.environment_token, "-", "")
  unique_suffix       = random_string.unique.result

  resource_group_name           = var.resource_group_name != "" ? var.resource_group_name : "rg-${local.workload_token}-${local.environment_token}-${local.loc_short}"
  aks_name                      = "aks-${local.workload_token}-${local.environment_token}-${local.loc_short}"
  acr_name                      = substr("acr${local.workload_compact}${local.environment_compact}${local.unique_suffix}", 0, 50)
  key_vault_name                = trimsuffix(substr("kv-${local.workload_token}-${local.environment_token}-${local.unique_suffix}", 0, 24), "-")
  log_analytics_name            = "log-${local.workload_token}-${local.environment_token}-${local.loc_short}"
  azure_monitor_workspace_name  = "amw-${local.workload_token}-${local.environment_token}-${local.loc_short}"
  grafana_name                  = "amg-${local.workload_token}-${local.environment_token}-${local.loc_short}"
  vnet_name                     = "vnet-${local.workload_token}-${local.environment_token}-${local.loc_short}"
  aks_identity_name             = "id-aks-${local.workload_token}-${local.environment_token}-${local.loc_short}"
  firewall_name                 = "afw-${local.workload_token}-${local.environment_token}-${local.loc_short}"
  route_table_name              = "rt-${local.workload_token}-${local.environment_token}-${local.loc_short}"
  data_collection_rule_name     = "dcr-prom-${local.workload_token}-${local.environment_token}-${local.loc_short}"
  data_collection_endpoint_name = "dce-${local.workload_token}-${local.environment_token}-${local.loc_short}"

  node_subnet_name             = "snet-aks-nodes"
  ingress_subnet_name          = "snet-ingress"
  private_endpoint_subnet_name = "snet-private-endpoints"
  api_server_subnet_name       = "snet-apiserver"

  tags = merge(var.tags, {
    Environment = local.environment_token
    Workload    = local.workload_token
    Track       = "Terraform"
    Owner       = "WS1"
  })

  diagnostic_settings = {
    law = {
      name                  = "diag"
      workspace_resource_id = module.log_analytics.resource_id
    }
  }

  node_subnet_resource_id             = module.vnet.subnets[local.node_subnet_name].resource_id
  private_endpoint_subnet_resource_id = module.vnet.subnets[local.private_endpoint_subnet_name].resource_id
  api_server_subnet_resource_id       = var.enable_api_server_vnet_integration ? module.vnet.subnets[local.api_server_subnet_name].resource_id : ""

  aks_outbound_type = var.deploy_firewall ? "userDefinedRouting" : var.outbound_type
}

