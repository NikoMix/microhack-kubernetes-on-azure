module "node_nsg" {
  #checkov:skip=CKV_TF_1:Terraform Registry AVM modules are pinned by explicit version per the MicroHack parity contract.
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.5.1"

  name                = "nsg-${local.node_subnet_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
  enable_telemetry    = var.enable_telemetry
  diagnostic_settings = local.diagnostic_settings
}

module "ingress_nsg" {
  #checkov:skip=CKV_TF_1:Terraform Registry AVM modules are pinned by explicit version per the MicroHack parity contract.
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.5.1"

  name                = "nsg-${local.ingress_subnet_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
  enable_telemetry    = var.enable_telemetry
  diagnostic_settings = local.diagnostic_settings

  security_rules = {
    allow_http_inbound = {
      name                       = "AllowHttpInbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "Internet"
      source_port_range          = "*"
      destination_address_prefix = "*"
      destination_port_range     = "80"
    }
    allow_https_inbound = {
      name                       = "AllowHttpsInbound"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "Internet"
      source_port_range          = "*"
      destination_address_prefix = "*"
      destination_port_range     = "443"
    }
  }
}

module "private_endpoint_nsg" {
  #checkov:skip=CKV_TF_1:Terraform Registry AVM modules are pinned by explicit version per the MicroHack parity contract.
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.5.1"

  name                = "nsg-${local.private_endpoint_subnet_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
  enable_telemetry    = var.enable_telemetry
  diagnostic_settings = local.diagnostic_settings
}

module "firewall_public_ip" {
  #checkov:skip=CKV_TF_1:Terraform Registry AVM modules are pinned by explicit version per the MicroHack parity contract.
  count = var.deploy_firewall ? 1 : 0

  source  = "Azure/avm-res-network-publicipaddress/azurerm"
  version = "0.2.1"

  name                = "pip-${local.firewall_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"
  zones               = toset(var.node_pool_availability_zones)
  tags                = local.tags
  enable_telemetry    = var.enable_telemetry
  diagnostic_settings = local.diagnostic_settings
}

module "egress_route_table" {
  #checkov:skip=CKV_TF_1:Terraform Registry AVM modules are pinned by explicit version per the MicroHack parity contract.
  count = var.deploy_firewall ? 1 : 0

  source  = "Azure/avm-res-network-routetable/azurerm"
  version = "0.5.0"

  name                = local.route_table_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
  enable_telemetry    = var.enable_telemetry
}

locals {
  node_subnet = merge({
    name                   = local.node_subnet_name
    address_prefix         = var.system_subnet_address_prefix
    network_security_group = { id = module.node_nsg.resource_id }
    }, var.deploy_firewall ? {
    route_table = { id = module.egress_route_table[0].resource_id }
  } : {})

  base_subnets = {
    (local.node_subnet_name) = local.node_subnet
    (local.ingress_subnet_name) = {
      name                   = local.ingress_subnet_name
      address_prefix         = var.ingress_subnet_address_prefix
      network_security_group = { id = module.ingress_nsg.resource_id }
    }
    (local.private_endpoint_subnet_name) = {
      name                                          = local.private_endpoint_subnet_name
      address_prefix                                = var.private_endpoint_subnet_address_prefix
      network_security_group                        = { id = module.private_endpoint_nsg.resource_id }
      private_endpoint_network_policies             = "Disabled"
      private_link_service_network_policies_enabled = false
    }
  }

  firewall_subnet = var.deploy_firewall ? {
    AzureFirewallSubnet = {
      name           = "AzureFirewallSubnet"
      address_prefix = var.firewall_subnet_address_prefix
    }
  } : {}

  api_server_subnet = var.enable_api_server_vnet_integration ? {
    (local.api_server_subnet_name) = {
      name           = local.api_server_subnet_name
      address_prefix = var.api_server_subnet_address_prefix
      delegations = [{
        name = "aks-api-server"
        service_delegation = {
          name = "Microsoft.ContainerService/managedClusters"
        }
      }]
    }
  } : {}
}

module "vnet" {
  #checkov:skip=CKV_TF_1:Terraform Registry AVM modules are pinned by explicit version per the MicroHack parity contract.
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.19.0"

  name                = local.vnet_name
  location            = azurerm_resource_group.this.location
  parent_id           = azurerm_resource_group.this.id
  address_space       = toset([var.vnet_address_space])
  subnets             = merge(local.base_subnets, local.firewall_subnet, local.api_server_subnet)
  tags                = local.tags
  enable_telemetry    = var.enable_telemetry
  diagnostic_settings = local.diagnostic_settings
}

module "firewall" {
  #checkov:skip=CKV_TF_1:Terraform Registry AVM modules are pinned by explicit version per the MicroHack parity contract.
  count = var.deploy_firewall ? 1 : 0

  source  = "Azure/avm-res-network-azurefirewall/azurerm"
  version = "0.4.0"

  name                = local.firewall_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  firewall_sku_name   = "AZFW_VNet"
  firewall_sku_tier   = "Standard"
  firewall_zones      = toset([for zone in var.node_pool_availability_zones : tostring(zone)])
  tags                = local.tags
  enable_telemetry    = var.enable_telemetry
  diagnostic_settings = local.diagnostic_settings

  ip_configurations = {
    default = {
      name                 = "ipconfig"
      public_ip_address_id = module.firewall_public_ip[0].resource_id
      subnet_id            = module.vnet.subnets["AzureFirewallSubnet"].resource_id
    }
  }
}

resource "azurerm_route" "default_to_firewall" {
  count = var.deploy_firewall ? 1 : 0

  name                   = "default-to-firewall"
  resource_group_name    = azurerm_resource_group.this.name
  route_table_name       = module.egress_route_table[0].name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = module.firewall[0].resource.ip_configuration[0].private_ip_address
}

