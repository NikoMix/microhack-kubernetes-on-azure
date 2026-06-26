// =============================================================================
//  AKS Secure Baseline — landing zone entry point (subscription-scoped).
//  Creates the resource group and orchestrates the AVM-based modules:
//  identity, observability, network, registry, key vault, AKS, post-deploy
//  wiring and an optional budget.
//
//  Validated with `az bicep build` / `az bicep lint`. Designed for parity with
//  the Terraform implementation under ../terraform.
// =============================================================================

targetScope = 'subscription'

metadata name = 'AKS secure baseline (AVM)'
metadata description = 'Microsoft Entra + Azure RBAC AKS cluster with CNI Overlay/Cilium, Workload Identity, ACR, Key Vault CSI, Defender, Azure Policy, and full Azure Monitor observability.'

// -------------------------------------------------------------------------
//  Core parameters
// -------------------------------------------------------------------------
@description('Optional. Azure region for all resources.')
param location string = 'westeurope'

@description('Optional. Environment short name (e.g. dev, test, prod).')
param environment string = 'dev'

@description('Optional. Workload short name used in resource naming.')
@minLength(2)
@maxLength(12)
param workloadName string = 'mhaks'

@description('Optional. Resource group name. Empty generates rg-{workload}-{env}-{loc}.')
param resourceGroupName string = ''

@description('Optional. Additional tags merged onto every resource.')
param tags object = {}

// -------------------------------------------------------------------------
//  Networking
// -------------------------------------------------------------------------
@description('Optional. VNet address space.')
param vnetAddressSpace string = '10.0.0.0/16'

@description('Optional. AKS node subnet prefix.')
param systemSubnetAddressPrefix string = '10.0.0.0/23'

@description('Optional. Ingress subnet prefix.')
param ingressSubnetAddressPrefix string = '10.0.4.0/24'

@description('Optional. Private endpoint subnet prefix.')
param privateEndpointSubnetAddressPrefix string = '10.0.5.0/24'

@description('Optional. Azure Firewall subnet prefix.')
param firewallSubnetAddressPrefix string = '10.0.6.0/26'

@description('Optional. API server subnet prefix (VNet integration).')
param apiServerSubnetAddressPrefix string = '10.0.7.0/28'

@description('Optional. Pod CIDR (overlay).')
param podCidr string = '10.244.0.0/16'

@description('Optional. Service CIDR.')
param serviceCidr string = '10.96.0.0/16'

@description('Optional. Kubernetes DNS service IP (within the service CIDR).')
param dnsServiceIP string = '10.96.0.10'

@description('Optional. Deploy Azure Firewall + UDR egress (forced tunneling).')
param deployFirewall bool = false

@description('Optional. Create a private endpoint subnet workflow for ACR/Key Vault.')
param enablePrivateEndpoints bool = false

// -------------------------------------------------------------------------
//  AKS
// -------------------------------------------------------------------------
@description('Optional. Kubernetes version. Empty selects the AKS default.')
param kubernetesVersion string = ''

@description('Optional. System node pool VM size.')
param systemNodePoolVmSize string = 'Standard_D4ds_v5'

@description('Optional. System node pool minimum node count.')
@minValue(1)
param systemNodePoolMinCount int = 1

@description('Optional. System node pool maximum node count.')
param systemNodePoolMaxCount int = 3

@description('Optional. User node pool VM size.')
param userNodePoolVmSize string = 'Standard_D4ds_v5'

@description('Optional. User node pool minimum node count.')
@minValue(1)
param userNodePoolMinCount int = 1

@description('Optional. User node pool maximum node count.')
param userNodePoolMaxCount int = 5

@description('Optional. Availability zones for node pools.')
param nodePoolAvailabilityZones int[] = [1, 2, 3]

@description('Optional. Microsoft Entra group object IDs granted cluster-admin via Azure RBAC.')
param adminGroupObjectIds array = []

@description('Optional. Enable Azure RBAC for Kubernetes authorization.')
param enableAzureRbac bool = true

@description('Optional. Disable local accounts (enforce Entra auth).')
param disableLocalAccounts bool = true

@description('Optional. Authorized IP ranges for the public API server.')
param authorizedIpRanges array = []

@description('Optional. Deploy a private cluster.')
param enablePrivateCluster bool = false

@description('Optional. Enable API server VNet integration.')
param enableApiServerVnetIntegration bool = false

@description('Optional. Network dataplane (azure or cilium).')
@allowed([
  'azure'
  'cilium'
])
param networkDataplane string = 'cilium'

@description('Optional. Cluster egress outbound type. Overridden to userDefinedRouting when deployFirewall=true.')
@allowed([
  'loadBalancer'
  'userDefinedRouting'
  'managedNATGateway'
])
param outboundType string = 'loadBalancer'

@description('Optional. Ingress controller type.')
@allowed([
  'none'
  'managedNginx'
  'appGatewayForContainers'
])
param ingressType string = 'managedNginx'

// -------------------------------------------------------------------------
//  Add-ons / security
// -------------------------------------------------------------------------
@description('Optional. Enable Workload Identity + OIDC issuer.')
param enableWorkloadIdentity bool = true

@description('Optional. Enable Key Vault Secret Store CSI driver + rotation.')
param enableKeyVaultCsi bool = true

@description('Optional. Enable Microsoft Defender for Containers (cluster profile).')
param enableDefenderForContainers bool = true

@description('Optional. Enable the Azure Policy add-on.')
param enableAzurePolicy bool = true

@description('Optional. Enable the image cleaner.')
param enableImageCleaner bool = true

// -------------------------------------------------------------------------
//  Observability
// -------------------------------------------------------------------------
@description('Optional. Enable Container Insights.')
param enableContainerInsights bool = true

@description('Optional. Enable Azure Monitor Managed Prometheus.')
param enableManagedPrometheus bool = true

@description('Optional. Enable Azure Managed Grafana.')
param enableManagedGrafana bool = true

@description('Optional. Microsoft Entra object IDs granted the Grafana Admin role.')
param grafanaAdminObjectIds array = []

@description('Optional. Log Analytics retention (days).')
@minValue(30)
@maxValue(730)
param logAnalyticsRetentionInDays int = 30

// -------------------------------------------------------------------------
//  Registry / Key Vault
// -------------------------------------------------------------------------
@description('Optional. ACR SKU.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param acrSku string = 'Premium'

// -------------------------------------------------------------------------
//  Cost
// -------------------------------------------------------------------------
@description('Optional. Create a resource-group budget.')
param enableBudget bool = true

@description('Optional. Monthly budget amount.')
param monthlyBudgetAmount int = 1000

@description('Optional. Budget alert email addresses.')
param budgetAlertEmails array = []

// -------------------------------------------------------------------------
//  Telemetry
// -------------------------------------------------------------------------
@description('Optional. Enable AVM module telemetry.')
param enableTelemetry bool = true

// -------------------------------------------------------------------------
//  Naming
// -------------------------------------------------------------------------
var locationShortMap = {
  westeurope: 'weu'
  northeurope: 'neu'
  eastus: 'eus'
  eastus2: 'eus2'
  westus: 'wus'
  westus2: 'wus2'
  westus3: 'wus3'
  centralus: 'cus'
  uksouth: 'uks'
  ukwest: 'ukw'
  francecentral: 'frc'
  germanywestcentral: 'gwc'
  switzerlandnorth: 'szn'
  swedencentral: 'sdc'
  norwayeast: 'nwe'
}
var locShort = locationShortMap[?location] ?? take(location, 3)
var rgName = empty(resourceGroupName) ? 'rg-${workloadName}-${environment}-${locShort}' : resourceGroupName
var uniq = toLower(substring(uniqueString(subscription().id, rgName, workloadName, environment), 0, 6))

var naming = {
  resourceGroup: rgName
  clusterIdentity: 'id-aks-${workloadName}-${environment}-${locShort}'
  vnet: 'vnet-${workloadName}-${environment}-${locShort}'
  nodeSubnet: 'snet-aks-nodes-${workloadName}-${environment}'
  ingressSubnet: 'snet-ingress-${workloadName}-${environment}'
  privateEndpointSubnet: 'snet-pe-${workloadName}-${environment}'
  firewall: '${workloadName}-${environment}-${locShort}'
  logAnalytics: 'log-${workloadName}-${environment}-${locShort}'
  azureMonitorWorkspace: 'amw-${workloadName}-${environment}-${locShort}'
  dataCollectionEndpoint: 'dce-${workloadName}-${environment}-${locShort}'
  dataCollectionRule: 'dcr-prom-${workloadName}-${environment}-${locShort}'
  grafana: 'amg-${workloadName}-${environment}-${locShort}'
  containerRegistry: toLower('acr${workloadName}${environment}${uniq}')
  keyVault: take('kv-${workloadName}-${environment}-${uniq}', 24)
  aksCluster: 'aks-${workloadName}-${environment}-${locShort}'
  nodeResourceGroup: 'rg-${workloadName}-${environment}-${locShort}-aks-nodes'
}

var effectiveOutboundType = deployFirewall ? 'userDefinedRouting' : outboundType

var baseTags = {
  workload: workloadName
  environment: environment
  'managed-by': 'bicep-avm'
}
var allTags = union(baseTags, tags)

// -------------------------------------------------------------------------
//  Resource group
// -------------------------------------------------------------------------
resource rg 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: rgName
  location: location
  tags: allTags
}

// -------------------------------------------------------------------------
//  Control-plane user-assigned identity
// -------------------------------------------------------------------------
module clusterIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.5.1' = {
  name: 'uami-deploy'
  scope: rg
  params: {
    name: naming.clusterIdentity
    location: location
    tags: allTags
    enableTelemetry: enableTelemetry
  }
}

// -------------------------------------------------------------------------
//  Observability (Log Analytics, AMW + Managed Prometheus, Grafana)
// -------------------------------------------------------------------------
module observability 'modules/observability.bicep' = {
  name: 'observability-deploy'
  scope: rg
  params: {
    location: location
    naming: naming
    tags: allTags
    logAnalyticsRetentionInDays: logAnalyticsRetentionInDays
    deployManagedPrometheus: enableManagedPrometheus
    deployGrafana: enableManagedGrafana
    grafanaAdminObjectIds: grafanaAdminObjectIds
    enableTelemetry: enableTelemetry
  }
}

// -------------------------------------------------------------------------
//  Network (VNet, subnets, NSGs, optional firewall, Network Contributor)
// -------------------------------------------------------------------------
module network 'modules/network.bicep' = {
  name: 'network-deploy'
  scope: rg
  params: {
    location: location
    naming: naming
    tags: allTags
    vnetAddressSpace: vnetAddressSpace
    systemSubnetAddressPrefix: systemSubnetAddressPrefix
    ingressSubnetAddressPrefix: ingressSubnetAddressPrefix
    privateEndpointSubnetAddressPrefix: privateEndpointSubnetAddressPrefix
    firewallSubnetAddressPrefix: firewallSubnetAddressPrefix
    apiServerSubnetAddressPrefix: apiServerSubnetAddressPrefix
    deployFirewall: deployFirewall
    enableApiServerVnetIntegration: enableApiServerVnetIntegration
    clusterIdentityPrincipalId: clusterIdentity.outputs.principalId
    logAnalyticsWorkspaceResourceId: observability.outputs.logAnalyticsWorkspaceResourceId
    enableTelemetry: enableTelemetry
  }
}

// -------------------------------------------------------------------------
//  Container Registry
// -------------------------------------------------------------------------
module registry 'modules/registry.bicep' = {
  name: 'registry-deploy'
  scope: rg
  params: {
    location: location
    naming: naming
    tags: allTags
    acrSku: acrSku
    logAnalyticsWorkspaceResourceId: observability.outputs.logAnalyticsWorkspaceResourceId
    enablePrivateEndpoints: enablePrivateEndpoints
    privateEndpointSubnetResourceId: enablePrivateEndpoints ? network.outputs.privateEndpointSubnetResourceId : ''
    enableTelemetry: enableTelemetry
  }
}

// -------------------------------------------------------------------------
//  Key Vault
// -------------------------------------------------------------------------
module keyVault 'modules/key-vault.bicep' = {
  name: 'keyvault-deploy'
  scope: rg
  params: {
    location: location
    naming: naming
    tags: allTags
    logAnalyticsWorkspaceResourceId: observability.outputs.logAnalyticsWorkspaceResourceId
    enablePrivateEndpoints: enablePrivateEndpoints
    privateEndpointSubnetResourceId: enablePrivateEndpoints ? network.outputs.privateEndpointSubnetResourceId : ''
    enableTelemetry: enableTelemetry
  }
}

// -------------------------------------------------------------------------
//  AKS cluster (depends on network Network Contributor via subnet reference)
// -------------------------------------------------------------------------
module aks 'modules/aks.bicep' = {
  name: 'aks-deploy'
  scope: rg
  params: {
    location: location
    naming: naming
    tags: allTags
    kubernetesVersion: kubernetesVersion
    systemNodePoolVmSize: systemNodePoolVmSize
    systemNodePoolMinCount: systemNodePoolMinCount
    systemNodePoolMaxCount: systemNodePoolMaxCount
    userNodePoolVmSize: userNodePoolVmSize
    userNodePoolMinCount: userNodePoolMinCount
    userNodePoolMaxCount: userNodePoolMaxCount
    nodePoolAvailabilityZones: nodePoolAvailabilityZones
    systemSubnetResourceId: network.outputs.systemSubnetResourceId
    apiServerSubnetResourceId: enableApiServerVnetIntegration ? network.outputs.apiServerSubnetResourceId : ''
    adminGroupObjectIds: adminGroupObjectIds
    enableAzureRbac: enableAzureRbac
    disableLocalAccounts: disableLocalAccounts
    authorizedIpRanges: authorizedIpRanges
    enablePrivateCluster: enablePrivateCluster
    enableApiServerVnetIntegration: enableApiServerVnetIntegration
    networkDataplane: networkDataplane
    podCidr: podCidr
    serviceCidr: serviceCidr
    dnsServiceIP: dnsServiceIP
    outboundType: effectiveOutboundType
    ingressType: ingressType
    enableWorkloadIdentity: enableWorkloadIdentity
    enableKeyVaultCsi: enableKeyVaultCsi
    enableDefenderForContainers: enableDefenderForContainers
    enableAzurePolicy: enableAzurePolicy
    enableImageCleaner: enableImageCleaner
    enableContainerInsights: enableContainerInsights
    enableManagedPrometheus: enableManagedPrometheus
    logAnalyticsWorkspaceResourceId: observability.outputs.logAnalyticsWorkspaceResourceId
    clusterIdentityResourceId: clusterIdentity.outputs.resourceId
    enableTelemetry: enableTelemetry
  }
}

// -------------------------------------------------------------------------
//  Post-deploy wiring (AcrPull, KV Secrets User, Prometheus DCRA)
// -------------------------------------------------------------------------
module postDeploy 'modules/post-deploy.bicep' = {
  name: 'post-deploy'
  scope: rg
  params: {
    naming: naming
    kubeletIdentityObjectId: aks.outputs.aksKubeletIdentityObjectId
    keyVaultCsiIdentityObjectId: aks.outputs.aksKeyVaultIdentityObjectId
    enableKeyVaultCsi: enableKeyVaultCsi
    deployManagedPrometheus: enableManagedPrometheus
    dataCollectionRuleResourceId: observability.outputs.dataCollectionRuleResourceId
  }
  dependsOn: [
    registry
    keyVault
  ]
}

// -------------------------------------------------------------------------
//  Optional budget
// -------------------------------------------------------------------------
module budget 'modules/budget.bicep' = if (enableBudget) {
  name: 'budget-deploy'
  scope: rg
  params: {
    budgetName: 'budget-${workloadName}-${environment}'
    monthlyBudgetAmount: monthlyBudgetAmount
    budgetAlertEmails: budgetAlertEmails
  }
}

// -------------------------------------------------------------------------
//  Outputs (consumed by WS2/WS3/GitOps — see CONTRACT)
// -------------------------------------------------------------------------
@description('Resource group name.')
output resourceGroupName string = rgName

@description('AKS cluster name.')
output aksClusterName string = aks.outputs.aksClusterName

@description('AKS cluster resource ID.')
output aksClusterResourceId string = aks.outputs.aksClusterResourceId

@description('AKS node (managed) resource group.')
output aksNodeResourceGroup string = aks.outputs.aksNodeResourceGroup

@description('AKS control plane FQDN.')
output aksControlPlaneFqdn string = aks.outputs.aksControlPlaneFqdn

@description('OIDC issuer URL for Workload Identity federation.')
output aksOidcIssuerUrl string = aks.outputs.aksOidcIssuerUrl

@description('Kubelet identity object ID.')
output aksKubeletIdentityObjectId string = aks.outputs.aksKubeletIdentityObjectId

@description('Kubelet identity client ID.')
output aksKubeletIdentityClientId string = aks.outputs.aksKubeletIdentityClientId

@description('Kubelet identity resource ID.')
output aksKubeletIdentityResourceId string = aks.outputs.aksKubeletIdentityResourceId

@description('Cluster system-assigned principal ID (empty for user-assigned identity).')
output aksClusterPrincipalId string = aks.outputs.aksClusterPrincipalId

@description('ACR name.')
output acrName string = registry.outputs.acrName

@description('ACR login server.')
output acrLoginServer string = registry.outputs.acrLoginServer

@description('ACR resource ID.')
output acrResourceId string = registry.outputs.acrResourceId

@description('Key Vault name.')
output keyVaultName string = keyVault.outputs.keyVaultName

@description('Key Vault URI.')
output keyVaultUri string = keyVault.outputs.keyVaultUri

@description('Key Vault resource ID.')
output keyVaultResourceId string = keyVault.outputs.keyVaultResourceId

@description('Log Analytics workspace resource ID.')
output logAnalyticsWorkspaceResourceId string = observability.outputs.logAnalyticsWorkspaceResourceId

@description('Azure Monitor Workspace resource ID (empty when Managed Prometheus disabled).')
output azureMonitorWorkspaceResourceId string = observability.outputs.azureMonitorWorkspaceResourceId

@description('Managed Grafana resource ID (empty when Grafana disabled).')
output grafanaResourceId string = observability.outputs.grafanaResourceId

@description('Managed Grafana endpoint (empty when Grafana disabled).')
output grafanaEndpoint string = observability.outputs.grafanaEndpoint

@description('VNet resource ID.')
output vnetResourceId string = network.outputs.vnetResourceId

@description('AKS node subnet resource ID.')
output systemSubnetResourceId string = network.outputs.systemSubnetResourceId

@description('Selected ingress controller type.')
output ingressType string = ingressType

@description('Command to fetch cluster credentials.')
output getCredentialsCommand string = 'az aks get-credentials --resource-group ${rgName} --name ${aks.outputs.aksClusterName} --overwrite-existing'
