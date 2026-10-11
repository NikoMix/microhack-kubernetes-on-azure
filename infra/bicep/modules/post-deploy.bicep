// =============================================================================
//  Post-deploy module — role assignments and associations that depend on the
//  cluster's runtime identities: AcrPull for the kubelet identity, Key Vault
//  Secrets User for the CSI add-on identity, and the Prometheus DCR association.
//  Deployed AFTER the AKS module.
// =============================================================================

metadata name = 'AKS baseline post-deploy wiring'
metadata description = 'Kubelet AcrPull, KV Secrets User, and Prometheus DCR association for the AKS cluster.'

@description('Required. Resource naming context.')
param naming object

@description('Required. Kubelet (node) identity object ID.')
param kubeletIdentityObjectId string

@description('Optional. Key Vault CSI add-on identity object ID.')
param keyVaultCsiIdentityObjectId string = ''

@description('Optional. Grant Key Vault Secrets User to the CSI identity.')
param enableKeyVaultCsi bool = true

@description('Optional. Associate the Prometheus Data Collection Rule with the cluster.')
param deployManagedPrometheus bool = true

@description('Optional. Prometheus Data Collection Rule resource ID.')
param dataCollectionRuleResourceId string = ''

var acrPullRoleId = '7f951dda-4ed3-4680-a7ca-43fe172d538d'
var keyVaultSecretsUserRoleId = '4633458b-17de-408a-b874-0445c86b69e6'

resource acrExisting 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name: naming.containerRegistry
}

resource keyVaultExisting 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: naming.keyVault
}

resource aksExisting 'Microsoft.ContainerService/managedClusters@2025-10-01' existing = {
  name: naming.aksCluster
}

// Kubelet identity may pull images from ACR (managed-identity, no credentials).
resource acrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(naming.containerRegistry, naming.aksCluster, acrPullRoleId)
  scope: acrExisting
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', acrPullRoleId)
    principalId: kubeletIdentityObjectId
    principalType: 'ServicePrincipal'
  }
}

// Key Vault CSI add-on identity may read secrets from Key Vault.
resource keyVaultSecretsUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (enableKeyVaultCsi && !empty(keyVaultCsiIdentityObjectId)) {
  name: guid(naming.keyVault, naming.aksCluster, keyVaultSecretsUserRoleId)
  scope: keyVaultExisting
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultSecretsUserRoleId)
    principalId: keyVaultCsiIdentityObjectId
    principalType: 'ServicePrincipal'
  }
}

// Associate the Prometheus DCR with the cluster so metrics flow to the AMW.
resource prometheusAssociation 'Microsoft.Insights/dataCollectionRuleAssociations@2023-03-11' = if (deployManagedPrometheus && !empty(dataCollectionRuleResourceId)) {
  name: 'dcra-prometheus'
  scope: aksExisting
  properties: {
    dataCollectionRuleId: dataCollectionRuleResourceId
    description: 'Associates the Managed Prometheus DCR with the AKS cluster.'
  }
}

@description('AcrPull role assignment resource ID.')
output acrPullRoleAssignmentId string = acrPull.id
