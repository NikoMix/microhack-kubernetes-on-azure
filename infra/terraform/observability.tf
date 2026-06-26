module "log_analytics" {
  #checkov:skip=CKV_TF_1:Terraform Registry AVM modules are pinned by explicit version per the MicroHack parity contract.
  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = "0.5.1"

  name                                                 = local.log_analytics_name
  location                                             = azurerm_resource_group.this.location
  resource_group_name                                  = azurerm_resource_group.this.name
  log_analytics_workspace_sku                          = "PerGB2018"
  log_analytics_workspace_retention_in_days            = var.log_analytics_retention_in_days
  log_analytics_workspace_daily_quota_gb               = -1
  log_analytics_workspace_local_authentication_enabled = false
  tags                                                 = local.tags
  enable_telemetry                                     = var.enable_telemetry
}

resource "azurerm_monitor_workspace" "prometheus" {
  count = var.enable_managed_prometheus ? 1 : 0

  name                          = local.azure_monitor_workspace_name
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  public_network_access_enabled = true
  tags                          = local.tags
}

resource "azurerm_monitor_data_collection_endpoint" "prometheus" {
  count = var.enable_managed_prometheus ? 1 : 0

  name                          = local.data_collection_endpoint_name
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  kind                          = "Linux"
  public_network_access_enabled = true
  tags                          = local.tags
}

resource "azurerm_monitor_data_collection_rule" "prometheus" {
  count = var.enable_managed_prometheus ? 1 : 0

  name                        = local.data_collection_rule_name
  resource_group_name         = azurerm_resource_group.this.name
  location                    = azurerm_resource_group.this.location
  kind                        = "Linux"
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.prometheus[0].id
  tags                        = local.tags

  destinations {
    monitor_account {
      monitor_account_id = azurerm_monitor_workspace.prometheus[0].id
      name               = "MonitoringAccount"
    }
  }

  data_sources {
    prometheus_forwarder {
      name    = "PrometheusDataSource"
      streams = ["Microsoft-PrometheusMetrics"]
    }
  }

  data_flow {
    streams      = ["Microsoft-PrometheusMetrics"]
    destinations = ["MonitoringAccount"]
  }
}

resource "azurerm_dashboard_grafana" "this" {
  count = var.enable_managed_grafana ? 1 : 0

  name                              = local.grafana_name
  resource_group_name               = azurerm_resource_group.this.name
  location                          = azurerm_resource_group.this.location
  grafana_major_version             = 12
  api_key_enabled                   = false
  deterministic_outbound_ip_enabled = false
  public_network_access_enabled     = true
  sku                               = "Standard"
  sku_size                          = "X1"
  zone_redundancy_enabled           = false
  tags                              = local.tags

  identity {
    type = "SystemAssigned"
  }

  dynamic "azure_monitor_workspace_integrations" {
    for_each = var.enable_managed_prometheus ? [azurerm_monitor_workspace.prometheus[0].id] : []
    content {
      resource_id = azure_monitor_workspace_integrations.value
    }
  }
}

resource "azurerm_role_assignment" "grafana_monitoring_data_reader" {
  count = var.enable_managed_grafana && var.enable_managed_prometheus ? 1 : 0

  scope                            = azurerm_monitor_workspace.prometheus[0].id
  role_definition_id               = "${data.azurerm_subscription.current.id}/providers/Microsoft.Authorization/roleDefinitions/b0d8363b-8ddd-447d-831f-62ca05bff136"
  principal_id                     = azurerm_dashboard_grafana.this[0].identity[0].principal_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "grafana_admins" {
  for_each = var.enable_managed_grafana ? toset(var.grafana_admin_object_ids) : toset([])

  scope              = azurerm_dashboard_grafana.this[0].id
  role_definition_id = "${data.azurerm_subscription.current.id}/providers/Microsoft.Authorization/roleDefinitions/22926164-76b3-42b3-bc55-97df8dab3e41"
  principal_id       = each.value
  principal_type     = "Group"
}

