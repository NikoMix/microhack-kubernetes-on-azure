# Cluster-level Defender is enabled here when requested. The subscription-level Defender for Containers plan must be enabled separately.
module "aks" {
  #checkov:skip=CKV_TF_1:Terraform Registry AVM modules are pinned by explicit version per the MicroHack parity contract.
  source  = "Azure/avm-res-containerservice-managedcluster/azurerm"
  version = "0.8.4"

  name                   = local.aks_name
  location               = azurerm_resource_group.this.location
  parent_id              = azurerm_resource_group.this.id
  dns_prefix             = local.aks_name
  kubernetes_version     = var.kubernetes_version == "" ? null : var.kubernetes_version
  enable_rbac            = true
  disable_local_accounts = var.disable_local_accounts
  public_network_access  = "Enabled"
  tags                   = local.tags
  enable_telemetry       = var.enable_telemetry

  managed_identities = {
    system_assigned            = false
    user_assigned_resource_ids = toset([module.aks_identity.resource_id])
  }

  aad_profile = {
    managed                = true
    enable_azure_rbac      = var.enable_azure_rbac
    admin_group_object_ids = var.admin_group_object_ids
  }

  oidc_issuer_profile = {
    enabled = var.enable_workload_identity
  }

  default_agent_pool = {
    name                = "systempool"
    vm_size             = var.system_node_pool_vm_size
    enable_auto_scaling = true
    min_count           = var.system_node_pool_min_count
    max_count           = var.system_node_pool_max_count
    mode                = "System"
    node_taints         = ["CriticalAddonsOnly=true:NoSchedule"]
    availability_zones  = [for zone in var.node_pool_availability_zones : tostring(zone)]
    vnet_subnet_id      = local.node_subnet_resource_id
    os_sku              = "AzureLinux"
    upgrade_settings = {
      max_surge = "33%"
    }
  }

  network_profile = {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_dataplane   = var.network_dataplane
    network_policy      = var.network_dataplane == "cilium" ? "cilium" : "azure"
    pod_cidr            = var.pod_cidr
    service_cidr        = var.service_cidr
    dns_service_ip      = var.dns_service_ip
    outbound_type       = local.aks_outbound_type
    load_balancer_sku   = "standard"
  }

  api_server_access_profile = {
    authorized_ip_ranges    = var.authorized_ip_ranges
    enable_private_cluster  = var.enable_private_cluster
    enable_vnet_integration = var.enable_api_server_vnet_integration
    subnet_id               = var.enable_api_server_vnet_integration ? local.api_server_subnet_resource_id : null
  }

  security_profile = {
    workload_identity = {
      enabled = var.enable_workload_identity
    }
    defender = var.enable_defender_for_containers ? {
      log_analytics_workspace_resource_id = module.log_analytics.resource_id
      security_monitoring = {
        enabled = true
      }
    } : null
    image_cleaner = {
      enabled        = var.enable_image_cleaner
      interval_hours = 48
    }
  }

  addon_profile_azure_policy = {
    enabled = var.enable_azure_policy
  }

  addon_profile_key_vault_secrets_provider = var.enable_key_vault_csi ? {
    enabled = true
    config = {
      enable_secret_rotation = true
      rotation_poll_interval = "2m"
    }
  } : null

  addon_profile_oms_agent = var.enable_container_insights ? {
    enabled = true
    config = {
      log_analytics_workspace_resource_id = module.log_analytics.resource_id
      use_aad_auth                        = true
    }
  } : null

  azure_monitor_profile = var.enable_managed_prometheus ? {
    metrics = {
      enabled = true
    }
  } : null

  ingress_profile = var.ingress_type == "managedNginx" ? {
    web_app_routing = {
      enabled = true
      nginx = {
        default_ingress_controller_type = "External"
      }
    }
  } : null

  auto_upgrade_profile = {
    upgrade_channel         = "stable"
    node_os_upgrade_channel = "NodeImage"
  }

  sku = {
    name = "Base"
    tier = "Standard"
  }

  diagnostic_settings = local.diagnostic_settings

  depends_on = [azurerm_role_assignment.aks_vnet_network_contributor]
}

resource "azapi_resource" "user_node_pool" {
  type      = "Microsoft.ContainerService/managedClusters/agentPools@2024-10-01"
  name      = "userpool"
  parent_id = module.aks.resource_id

  body = {
    properties = {
      mode                = "User"
      osType              = "Linux"
      osSKU               = "AzureLinux"
      vmSize              = var.user_node_pool_vm_size
      count               = var.user_node_pool_min_count
      enableAutoScaling   = true
      minCount            = var.user_node_pool_min_count
      maxCount            = var.user_node_pool_max_count
      availabilityZones   = [for zone in var.node_pool_availability_zones : tostring(zone)]
      type                = "VirtualMachineScaleSets"
      vnetSubnetID        = local.node_subnet_resource_id
      orchestratorVersion = var.kubernetes_version == "" ? null : var.kubernetes_version
      upgradeSettings = {
        maxSurge = "33%"
      }
    }
  }
}

