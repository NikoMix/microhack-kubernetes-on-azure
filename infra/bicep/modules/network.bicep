// =============================================================================
//  Network module — hub/spoke-ready VNet, subnets, NSGs, optional Azure Firewall
//  egress (UDR), and the cluster identity's Network Contributor assignment.
//  AVM-first: virtual-network, network-security-group, azure-firewall,
//  public-ip-address, route-table.
// =============================================================================

metadata name = 'AKS baseline network'
metadata description = 'Spoke VNet with AKS node/ingress/private-endpoint subnets, optional API-server and Azure Firewall subnets, NSGs and UDR egress.'

@description('Required. Azure region for all network resources.')
param location string

@description('Required. Resource naming context.')
param naming object

@description('Required. Tags applied to all resources.')
param tags object

@description('Required. VNet address space (CIDR).')
param vnetAddressSpace string

@description('Required. AKS node subnet prefix (system + user pools).')
param systemSubnetAddressPrefix string

@description('Required. Ingress subnet prefix (App Gateway for Containers / managed NGINX LB).')
param ingressSubnetAddressPrefix string

@description('Required. Private endpoint subnet prefix.')
param privateEndpointSubnetAddressPrefix string

@description('Required. Azure Firewall subnet prefix (used only when deployFirewall=true).')
param firewallSubnetAddressPrefix string

@description('Required. API server subnet prefix (used only when enableApiServerVnetIntegration=true).')
param apiServerSubnetAddressPrefix string

@description('Optional. Deploy Azure Firewall + route table for forced-tunnel (UDR) egress.')
param deployFirewall bool = false

@description('Optional. Reserve an API-server VNet-integration subnet.')
param enableApiServerVnetIntegration bool = false

@description('Required. Principal ID of the cluster (control-plane) user-assigned identity to grant Network Contributor on the VNet.')
param clusterIdentityPrincipalId string

@description('Required. Log Analytics workspace resource ID for diagnostics.')
param logAnalyticsWorkspaceResourceId string

@description('Optional. Enable AVM telemetry.')
param enableTelemetry bool = true

// Network Contributor — required for the AKS control-plane identity to manage
// load balancers / subnets when bringing your own VNet.
var networkContributorRoleId = '4d97b98b-1d4f-4787-a291-c67834d212e7'

var nodeSubnetName = 'snet-aks-nodes'
var ingressSubnetName = 'snet-ingress'
var privateEndpointSubnetName = 'snet-private-endpoints'
var apiServerSubnetName = 'snet-apiserver'

// --- NSGs (node / ingress / private-endpoint subnets). AzureFirewallSubnet must NOT have an NSG. ---
module nodeNsg 'br/public:avm/res/network/network-security-group:0.5.3' = {
  name: 'nsg-nodes-deploy'
  params: {
    name: 'nsg-${naming.nodeSubnet}'
    location: location
    tags: tags
    enableTelemetry: enableTelemetry
    diagnosticSettings: [
      {
        name: 'diag'
        workspaceResourceId: logAnalyticsWorkspaceResourceId
      }
    ]
  }
}

module ingressNsg 'br/public:avm/res/network/network-security-group:0.5.3' = {
  name: 'nsg-ingress-deploy'
  params: {
    name: 'nsg-${naming.ingressSubnet}'
    location: location
    tags: tags
    enableTelemetry: enableTelemetry
    securityRules: [
      {
        name: 'AllowHttpInbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '80'
        }
      }
      {
        name: 'AllowHttpsInbound'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
        }
      }
    ]
    diagnosticSettings: [
      {
        name: 'diag'
        workspaceResourceId: logAnalyticsWorkspaceResourceId
      }
    ]
  }
}

module privateEndpointNsg 'br/public:avm/res/network/network-security-group:0.5.3' = {
  name: 'nsg-pe-deploy'
  params: {
    name: 'nsg-${naming.privateEndpointSubnet}'
    location: location
    tags: tags
    enableTelemetry: enableTelemetry
    diagnosticSettings: [
      {
        name: 'diag'
        workspaceResourceId: logAnalyticsWorkspaceResourceId
      }
    ]
  }
}

// --- Optional Azure Firewall egress (public IP + route table created first, route added after FW) ---
module firewallPublicIp 'br/public:avm/res/network/public-ip-address:0.12.0' = if (deployFirewall) {
  name: 'pip-afw-deploy'
  params: {
    name: 'pip-${naming.firewall}'
    location: location
    tags: tags
    enableTelemetry: enableTelemetry
    skuName: 'Standard'
    skuTier: 'Regional'
    publicIPAllocationMethod: 'Static'
    availabilityZones: [1, 2, 3]
    diagnosticSettings: [
      {
        name: 'diag'
        workspaceResourceId: logAnalyticsWorkspaceResourceId
      }
    ]
  }
}

module egressRouteTable 'br/public:avm/res/network/route-table:0.5.0' = if (deployFirewall) {
  name: 'rt-egress-deploy'
  params: {
    name: 'rt-${naming.firewall}'
    location: location
    tags: tags
    enableTelemetry: enableTelemetry
    // Routes are added after the firewall is provisioned (see defaultEgressRoute).
  }
}

// Build subnet definitions. Node subnet references the route table only when forced-tunneling.
var nodeSubnetBase = {
  name: nodeSubnetName
  addressPrefix: systemSubnetAddressPrefix
  networkSecurityGroupResourceId: nodeNsg.outputs.resourceId
}

var baseSubnets = [
  deployFirewall
    ? union(nodeSubnetBase, { routeTableResourceId: egressRouteTable!.outputs.resourceId })
    : nodeSubnetBase
  {
    name: ingressSubnetName
    addressPrefix: ingressSubnetAddressPrefix
    networkSecurityGroupResourceId: ingressNsg.outputs.resourceId
  }
  {
    name: privateEndpointSubnetName
    addressPrefix: privateEndpointSubnetAddressPrefix
    networkSecurityGroupResourceId: privateEndpointNsg.outputs.resourceId
  }
]

var firewallSubnet = deployFirewall ? [
  {
    name: 'AzureFirewallSubnet'
    addressPrefix: firewallSubnetAddressPrefix
  }
] : []

var apiServerSubnet = enableApiServerVnetIntegration ? [
  {
    name: apiServerSubnetName
    addressPrefix: apiServerSubnetAddressPrefix
    delegation: 'Microsoft.ContainerService/managedClusters'
  }
] : []

var allSubnets = concat(baseSubnets, firewallSubnet, apiServerSubnet)

module vnet 'br/public:avm/res/network/virtual-network:0.9.0' = {
  name: 'vnet-deploy'
  params: {
    name: naming.vnet
    location: location
    tags: tags
    enableTelemetry: enableTelemetry
    addressPrefixes: [vnetAddressSpace]
    subnets: allSubnets
    diagnosticSettings: [
      {
        name: 'diag'
        workspaceResourceId: logAnalyticsWorkspaceResourceId
      }
    ]
  }
}

module firewall 'br/public:avm/res/network/azure-firewall:0.10.1' = if (deployFirewall) {
  name: 'afw-deploy'
  params: {
    name: 'afw-${naming.firewall}'
    location: location
    tags: tags
    enableTelemetry: enableTelemetry
    azureSkuTier: 'Standard'
    virtualNetworkResourceId: vnet.outputs.resourceId
    publicIPResourceID: deployFirewall ? firewallPublicIp!.outputs.resourceId : ''
    availabilityZones: [1, 2, 3]
    diagnosticSettings: [
      {
        name: 'diag'
        workspaceResourceId: logAnalyticsWorkspaceResourceId
      }
    ]
  }
}

// Default egress route 0.0.0.0/0 -> firewall private IP (added once firewall exists).
resource routeTableExisting 'Microsoft.Network/routeTables@2024-05-01' existing = if (deployFirewall) {
  name: 'rt-${naming.firewall}'
}

resource defaultEgressRoute 'Microsoft.Network/routeTables/routes@2024-05-01' = if (deployFirewall) {
  parent: routeTableExisting
  name: 'default-to-firewall'
  properties: {
    addressPrefix: '0.0.0.0/0'
    nextHopType: 'VirtualAppliance'
    nextHopIpAddress: firewall!.outputs.privateIp
  }
}

// Grant the cluster identity Network Contributor on the VNet (required before AKS deploys).
resource vnetExisting 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: naming.vnet
}

resource clusterNetworkContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(naming.vnet, networkContributorRoleId, 'aks-cluster-identity')
  scope: vnetExisting
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', networkContributorRoleId)
    principalId: clusterIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

@description('VNet resource ID.')
output vnetResourceId string = vnet.outputs.resourceId

@description('AKS node subnet resource ID.')
output systemSubnetResourceId string = vnet.outputs.subnetResourceIds[0]

@description('Ingress subnet resource ID.')
output ingressSubnetResourceId string = vnet.outputs.subnetResourceIds[1]

@description('Private endpoint subnet resource ID.')
output privateEndpointSubnetResourceId string = vnet.outputs.subnetResourceIds[2]

@description('API server subnet resource ID (empty when VNet integration is disabled).')
output apiServerSubnetResourceId string = enableApiServerVnetIntegration
  ? vnet.outputs.subnetResourceIds[3 + (deployFirewall ? 1 : 0)]
  : ''

@description('Network Contributor role assignment resource ID (gate for AKS deployment ordering).')
output clusterNetworkContributorId string = clusterNetworkContributor.id
