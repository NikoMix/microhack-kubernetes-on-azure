// =============================================================================
//  Container Registry module — ACR (Premium) with managed-identity pull only,
//  no anonymous/admin access, retention + diagnostics. AVM-first.
// =============================================================================

metadata name = 'AKS baseline container registry'
metadata description = 'Azure Container Registry (Premium) hardened for managed-identity pull from AKS.'

@description('Required. Azure region.')
param location string

@description('Required. Resource naming context.')
param naming object

@description('Required. Tags applied to all resources.')
param tags object

@description('Optional. ACR SKU. Premium is required for private endpoints, zone redundancy and content trust.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param acrSku string = 'Premium'

@description('Required. Log Analytics workspace resource ID for diagnostics.')
param logAnalyticsWorkspaceResourceId string

@description('Optional. Restrict public network access and create a private endpoint.')
param enablePrivateEndpoints bool = false

@description('Optional. Private endpoint subnet resource ID (required when enablePrivateEndpoints=true).')
param privateEndpointSubnetResourceId string = ''

@description('Optional. Enable AVM telemetry.')
param enableTelemetry bool = true

module registry 'br/public:avm/res/container-registry/registry:0.12.1' = {
  name: 'acr-deploy'
  params: {
    name: naming.containerRegistry
    location: location
    tags: tags
    enableTelemetry: enableTelemetry
    acrSku: acrSku
    acrAdminUserEnabled: false
    anonymousPullEnabled: false
    publicNetworkAccess: enablePrivateEndpoints ? 'Disabled' : 'Enabled'
    networkRuleBypassOptions: 'AzureServices'
    zoneRedundancy: acrSku == 'Premium' ? 'Enabled' : 'Disabled'
    retentionPolicyStatus: acrSku == 'Premium' ? 'enabled' : 'disabled'
    retentionPolicyDays: 7
    exportPolicyStatus: 'enabled'
    diagnosticSettings: [
      {
        name: 'diag'
        workspaceResourceId: logAnalyticsWorkspaceResourceId
      }
    ]
    privateEndpoints: enablePrivateEndpoints ? [
      {
        subnetResourceId: privateEndpointSubnetResourceId
        service: 'registry'
      }
    ] : []
  }
}

@description('ACR name.')
output acrName string = registry.outputs.name

@description('ACR login server (FQDN).')
output acrLoginServer string = registry.outputs.loginServer

@description('ACR resource ID.')
output acrResourceId string = registry.outputs.resourceId
