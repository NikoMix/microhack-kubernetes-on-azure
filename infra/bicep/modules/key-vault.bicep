// =============================================================================
//  Key Vault module — RBAC-authorized vault with purge protection, soft delete
//  and diagnostics. Backs the Secret Store CSI driver on AKS. AVM-first.
// =============================================================================

metadata name = 'AKS baseline key vault'
metadata description = 'Azure Key Vault (RBAC, purge protection) for the Secret Store CSI driver.'

@description('Required. Azure region.')
param location string

@description('Required. Resource naming context.')
param naming object

@description('Required. Tags applied to all resources.')
param tags object

@description('Required. Log Analytics workspace resource ID for diagnostics.')
param logAnalyticsWorkspaceResourceId string

@description('Optional. Key Vault SKU.')
@allowed([
  'standard'
  'premium'
])
param skuName string = 'standard'

@description('Optional. Restrict public network access and create a private endpoint.')
param enablePrivateEndpoints bool = false

@description('Optional. Private endpoint subnet resource ID (required when enablePrivateEndpoints=true).')
param privateEndpointSubnetResourceId string = ''

@description('Optional. Enable AVM telemetry.')
param enableTelemetry bool = true

module vault 'br/public:avm/res/key-vault/vault:0.13.3' = {
  name: 'kv-deploy'
  params: {
    name: naming.keyVault
    location: location
    tags: tags
    enableTelemetry: enableTelemetry
    sku: skuName
    enableRbacAuthorization: true
    enablePurgeProtection: true
    softDeleteRetentionInDays: 90
    enableVaultForDeployment: false
    enableVaultForTemplateDeployment: false
    enableVaultForDiskEncryption: false
    publicNetworkAccess: enablePrivateEndpoints ? 'Disabled' : 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: enablePrivateEndpoints ? 'Deny' : 'Allow'
    }
    diagnosticSettings: [
      {
        name: 'diag'
        workspaceResourceId: logAnalyticsWorkspaceResourceId
      }
    ]
    privateEndpoints: enablePrivateEndpoints ? [
      {
        subnetResourceId: privateEndpointSubnetResourceId
        service: 'vault'
      }
    ] : []
  }
}

@description('Key Vault name.')
output keyVaultName string = vault.outputs.name

@description('Key Vault URI.')
output keyVaultUri string = vault.outputs.uri

@description('Key Vault resource ID.')
output keyVaultResourceId string = vault.outputs.resourceId
