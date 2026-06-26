variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "westeurope"
}

variable "environment" {
  description = "Environment name used in resource names and tags."
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,12}$", var.environment))
    error_message = "environment must be 1-12 alphanumeric or dash characters."
  }
}

variable "workload_name" {
  description = "Short workload name used in resource names."
  type        = string
  default     = "mhaks"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,20}$", var.workload_name))
    error_message = "workload_name must be 1-20 alphanumeric or dash characters."
  }
}

variable "resource_group_name" {
  description = "Resource group name. Empty string derives rg-{workload}-{environment}-{locShort}."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags merged with baseline tags."
  type        = map(string)
  default     = {}
}

variable "vnet_address_space" {
  description = "VNet address space."
  type        = string
  default     = "10.0.0.0/16"
}

variable "system_subnet_address_prefix" {
  description = "AKS node subnet prefix for system and user node pools."
  type        = string
  default     = "10.0.0.0/23"
}

variable "ingress_subnet_address_prefix" {
  description = "Ingress subnet prefix."
  type        = string
  default     = "10.0.4.0/24"
}

variable "private_endpoint_subnet_address_prefix" {
  description = "Private endpoint subnet prefix."
  type        = string
  default     = "10.0.5.0/24"
}

variable "firewall_subnet_address_prefix" {
  description = "AzureFirewallSubnet prefix used when deploy_firewall is true."
  type        = string
  default     = "10.0.6.0/26"
}

variable "api_server_subnet_address_prefix" {
  description = "API server VNet integration subnet prefix."
  type        = string
  default     = "10.0.7.0/28"
}

variable "pod_cidr" {
  description = "Kubernetes pod CIDR for Azure CNI Overlay."
  type        = string
  default     = "10.244.0.0/16"
}

variable "service_cidr" {
  description = "Kubernetes service CIDR."
  type        = string
  default     = "10.96.0.0/16"
}

variable "dns_service_ip" {
  description = "Kubernetes DNS service IP."
  type        = string
  default     = "10.96.0.10"
}

variable "kubernetes_version" {
  description = "AKS Kubernetes version. Empty string lets Azure choose the default."
  type        = string
  default     = ""
}

variable "system_node_pool_vm_size" {
  description = "System node pool VM size."
  type        = string
  default     = "Standard_D4ds_v5"
}

variable "system_node_pool_min_count" {
  description = "Minimum system node pool count."
  type        = number
  default     = 1
}

variable "system_node_pool_max_count" {
  description = "Maximum system node pool count."
  type        = number
  default     = 3
}

variable "user_node_pool_vm_size" {
  description = "User node pool VM size."
  type        = string
  default     = "Standard_D4ds_v5"
}

variable "user_node_pool_min_count" {
  description = "Minimum user node pool count."
  type        = number
  default     = 1
}

variable "user_node_pool_max_count" {
  description = "Maximum user node pool count."
  type        = number
  default     = 5
}

variable "node_pool_availability_zones" {
  description = "Availability zones for AKS node pools."
  type        = list(number)
  default     = [1, 2, 3]
}

variable "admin_group_object_ids" {
  description = "Microsoft Entra group object IDs with AKS admin access."
  type        = list(string)
  default     = []
}

variable "enable_azure_rbac" {
  description = "Enable Azure RBAC for Kubernetes authorization."
  type        = bool
  default     = true
}

variable "disable_local_accounts" {
  description = "Disable AKS local accounts. Requires Microsoft Entra integration."
  type        = bool
  default     = true
}

variable "authorized_ip_ranges" {
  description = "Authorized public IP ranges for the AKS API server."
  type        = list(string)
  default     = []
}

variable "enable_private_cluster" {
  description = "Enable private AKS API server."
  type        = bool
  default     = false
}

variable "enable_api_server_vnet_integration" {
  description = "Enable API server VNet integration and create delegated subnet."
  type        = bool
  default     = false
}

variable "network_dataplane" {
  description = "AKS network dataplane."
  type        = string
  default     = "cilium"

  validation {
    condition     = contains(["azure", "cilium"], var.network_dataplane)
    error_message = "network_dataplane must be azure or cilium."
  }
}

variable "outbound_type" {
  description = "AKS outbound type when deploy_firewall is false."
  type        = string
  default     = "loadBalancer"

  validation {
    condition     = contains(["loadBalancer", "managedNATGateway", "userAssignedNATGateway", "userDefinedRouting"], var.outbound_type)
    error_message = "outbound_type must be a supported AKS outbound type."
  }
}

variable "deploy_firewall" {
  description = "Deploy Azure Firewall and UDR egress."
  type        = bool
  default     = false
}

variable "ingress_type" {
  description = "Ingress implementation toggle."
  type        = string
  default     = "managedNginx"

  validation {
    condition     = contains(["none", "managedNginx", "appGatewayForContainers"], var.ingress_type)
    error_message = "ingress_type must be none, managedNginx, or appGatewayForContainers."
  }
}

variable "enable_workload_identity" {
  description = "Enable AKS Workload Identity."
  type        = bool
  default     = true
}

variable "enable_key_vault_csi" {
  description = "Enable AKS Key Vault CSI driver with secret rotation."
  type        = bool
  default     = true
}

variable "enable_defender_for_containers" {
  description = "Enable AKS cluster-level Defender profile backed by Log Analytics."
  type        = bool
  default     = true
}

variable "enable_azure_policy" {
  description = "Enable AKS Azure Policy add-on."
  type        = bool
  default     = true
}

variable "enable_image_cleaner" {
  description = "Enable AKS image cleaner."
  type        = bool
  default     = true
}

variable "enable_container_insights" {
  description = "Enable Container Insights OMS agent with AAD auth."
  type        = bool
  default     = true
}

variable "enable_managed_prometheus" {
  description = "Enable Azure Monitor managed Prometheus resources and AKS metrics profile."
  type        = bool
  default     = true
}

variable "enable_managed_grafana" {
  description = "Deploy Azure Managed Grafana."
  type        = bool
  default     = true
}

variable "grafana_admin_object_ids" {
  description = "Microsoft Entra object IDs assigned Grafana Admin on the Grafana resource."
  type        = list(string)
  default     = []
}

variable "log_analytics_retention_in_days" {
  description = "Log Analytics retention in days."
  type        = number
  default     = 30

  validation {
    condition     = var.log_analytics_retention_in_days >= 30 && var.log_analytics_retention_in_days <= 730
    error_message = "log_analytics_retention_in_days must be between 30 and 730."
  }
}

variable "acr_sku" {
  description = "Azure Container Registry SKU."
  type        = string
  default     = "Premium"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "acr_sku must be Basic, Standard, or Premium."
  }
}

variable "enable_private_endpoints" {
  description = "Use private endpoints and disable public network access for ACR and Key Vault."
  type        = bool
  default     = false
}

variable "enable_budget" {
  description = "Enable a resource-group budget when budget_alert_emails is non-empty."
  type        = bool
  default     = true
}

variable "monthly_budget_amount" {
  description = "Monthly budget amount."
  type        = number
  default     = 1000
}

variable "budget_alert_emails" {
  description = "Budget alert email recipients."
  type        = list(string)
  default     = []
}

variable "enable_telemetry" {
  description = "Enable AVM module telemetry."
  type        = bool
  default     = true
}

