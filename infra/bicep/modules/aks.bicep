// =============================================================================
//  AKS module — secure-baseline managed cluster via AVM. Microsoft Entra +
//  Azure RBAC, Workload Identity/OIDC, Azure CNI Overlay (+Cilium), user-assigned
//  control-plane identity, Defender, Azure Policy, KV CSI, Container Insights,
//  Managed Prometheus, image cleaner, auto-upgrade + maintenance windows.
// =============================================================================

metadata name = 'AKS baseline cluster'
metadata description = 'Azure Kubernetes Service secure-baseline cluster (AVM managed-cluster).'

@description('Required. Azure region.')
param location string

@description('Required. Resource naming context.')
param naming object

@description('Required. Tags applied to the cluster.')
param tags object

@description('Optional. Kubernetes version. Empty selects the AKS default.')
param kubernetesVersion string = ''

@description('Required. System node pool VM size.')
param systemNodePoolVmSize string

@description('Required. System node pool minimum node count.')
param systemNodePoolMinCount int

@description('Required. System node pool maximum node count.')
param systemNodePoolMaxCount int

@description('Required. User node pool VM size.')
param userNodePoolVmSize string

@description('Required. User node pool minimum node count.')
param userNodePoolMinCount int

@description('Required. User node pool maximum node count.')
param userNodePoolMaxCount int

@description('Optional. Availability zones for the node pools.')
param nodePoolAvailabilityZones int[] = [1, 2, 3]

@description('Required. AKS node subnet resource ID.')
param systemSubnetResourceId string

@description('Optional. API server subnet resource ID (used with VNet integration).')
param apiServerSubnetResourceId string = ''

@description('Optional. Microsoft Entra group object IDs with cluster-admin via Azure RBAC.')
param adminGroupObjectIds array = []

@description('Optional. Enable Azure RBAC for Kubernetes authorization.')
param enableAzureRbac bool = true

@description('Optional. Disable local (certificate) accounts; enforce Entra auth.')
param disableLocalAccounts bool = true

@description('Optional. Authorized IP ranges for the public API server.')
param authorizedIpRanges array = []

@description('Optional. Deploy a private cluster.')
param enablePrivateCluster bool = false

@description('Optional. Enable API server VNet integration.')
param enableApiServerVnetIntegration bool = false

@description('Optional. Network dataplane: azure or cilium.')
@allowed([
  'azure'
  'cilium'
])
param networkDataplane string = 'cilium'

@description('Required. Pod CIDR (overlay).')
param podCidr string

@description('Required. Service CIDR.')
param serviceCidr string

@description('Required. Kubernetes DNS service IP.')
param dnsServiceIP string

@description('Optional. Cluster egress outbound type.')
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

@description('Optional. Enable Workload Identity (+ OIDC issuer).')
param enableWorkloadIdentity bool = true

@description('Optional. Enable Key Vault Secret Store CSI driver + rotation.')
param enableKeyVaultCsi bool = true

@description('Optional. Enable Microsoft Defender for Containers (cluster profile).')
param enableDefenderForContainers bool = true

@description('Optional. Enable the Azure Policy add-on.')
param enableAzurePolicy bool = true

@description('Optional. Enable the image cleaner (Eraser).')
param enableImageCleaner bool = true

@description('Optional. Enable Container Insights (OMS agent, MSI auth).')
param enableContainerInsights bool = true

@description('Optional. Enable Azure Monitor Managed Prometheus metrics on the cluster.')
param enableManagedPrometheus bool = true

@description('Required. Log Analytics workspace resource ID (Container Insights + Defender).')
param logAnalyticsWorkspaceResourceId string

@description('Required. Control-plane user-assigned identity resource ID.')
param clusterIdentityResourceId string

@description('Optional. Enable AVM telemetry.')
param enableTelemetry bool = true

// --- Node pools ---
var systemAgentPool = {
  name: 'system'
  mode: 'System'
  vmSize: systemNodePoolVmSize
  count: systemNodePoolMinCount
  minCount: systemNodePoolMinCount
  maxCount: systemNodePoolMaxCount
  enableAutoScaling: true
  availabilityZones: nodePoolAvailabilityZones
  vnetSubnetResourceId: systemSubnetResourceId
  osType: 'Linux'
  osSKU: 'AzureLinux'
  osDiskType: 'Ephemeral'
  type: 'VirtualMachineScaleSets'
  nodeTaints: [
    'CriticalAddonsOnly=true:NoSchedule'
  ]
}

var userAgentPool = {
  name: 'user'
  mode: 'User'
  vmSize: userNodePoolVmSize
  count: userNodePoolMinCount
  minCount: userNodePoolMinCount
  maxCount: userNodePoolMaxCount
  enableAutoScaling: true
  availabilityZones: nodePoolAvailabilityZones
  vnetSubnetResourceId: systemSubnetResourceId
  osType: 'Linux'
  osSKU: 'AzureLinux'
  osDiskType: 'Ephemeral'
  type: 'VirtualMachineScaleSets'
}

// --- Security profile (workload identity, image cleaner, optional Defender) ---
var baseSecurityProfile = {
  workloadIdentity: {
    enabled: enableWorkloadIdentity
  }
  imageCleaner: {
    enabled: enableImageCleaner
    intervalHours: 24
  }
}

var securityProfileValue = enableDefenderForContainers
  ? union(baseSecurityProfile, {
      defender: {
        logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
        securityMonitoring: {
          enabled: true
        }
      }
    })
  : baseSecurityProfile

// --- API server access ---
var apiServerAccessProfileValue = {
  authorizedIPRanges: empty(authorizedIpRanges) ? null : authorizedIpRanges
  enablePrivateCluster: enablePrivateCluster
  enableVnetIntegration: enableApiServerVnetIntegration
  subnetId: empty(apiServerSubnetResourceId) ? null : apiServerSubnetResourceId
}

// --- Maintenance windows: cluster auto-upgrade + node OS patching ---
var maintenanceConfigs = [
  {
    name: 'aksManagedAutoUpgradeSchedule'
    maintenanceWindow: {
      schedule: {
        weekly: {
          intervalWeeks: 1
          dayOfWeek: 'Sunday'
        }
      }
      durationHours: 4
      utcOffset: '+00:00'
      startTime: '03:00'
    }
  }
  {
    name: 'aksManagedNodeOSUpgradeSchedule'
    maintenanceWindow: {
      schedule: {
        weekly: {
          intervalWeeks: 1
          dayOfWeek: 'Sunday'
        }
      }
      durationHours: 4
      utcOffset: '+00:00'
      startTime: '07:00'
    }
  }
]

module managedCluster 'br/public:avm/res/container-service/managed-cluster:0.13.1' = {
  name: 'aks-deploy'
  params: {
    name: naming.aksCluster
    location: location
    tags: tags
    enableTelemetry: enableTelemetry
    kubernetesVersion: empty(kubernetesVersion) ? null : kubernetesVersion
    nodeResourceGroup: naming.nodeResourceGroup
    skuTier: 'Standard'
    skuName: 'Base'
    costAnalysisEnabled: true

    managedIdentities: {
      userAssignedResourceIds: [
        clusterIdentityResourceId
      ]
    }

    primaryAgentPoolProfiles: [
      systemAgentPool
    ]
    agentPools: [
      userAgentPool
    ]

    // Identity & access
    aadProfile: {
      managed: true
      enableAzureRBAC: enableAzureRbac
      adminGroupObjectIDs: adminGroupObjectIds
      tenantID: tenant().tenantId
    }
    enableRBAC: true
    disableLocalAccounts: disableLocalAccounts
    enableOidcIssuerProfile: true
    securityProfile: securityProfileValue

    // Networking (Azure CNI Overlay, optional Cilium dataplane)
    networkPlugin: 'azure'
    networkPluginMode: 'overlay'
    networkDataplane: networkDataplane
    networkPolicy: networkDataplane == 'cilium' ? 'cilium' : 'azure'
    podCidr: podCidr
    serviceCidr: serviceCidr
    dnsServiceIP: dnsServiceIP
    outboundType: outboundType
    loadBalancerSku: 'standard'
    publicNetworkAccess: enablePrivateCluster ? 'Disabled' : 'Enabled'
    apiServerAccessProfile: apiServerAccessProfileValue

    // Add-ons & governance
    azurePolicyEnabled: enableAzurePolicy
    azurePolicyVersion: 'v2'
    enableKeyvaultSecretsProvider: enableKeyVaultCsi
    enableSecretRotation: enableKeyVaultCsi
    omsAgentEnabled: enableContainerInsights
    omsAgentUseAADAuth: true
    monitoringWorkspaceResourceId: enableContainerInsights ? logAnalyticsWorkspaceResourceId : null
    azureMonitorProfile: enableManagedPrometheus
      ? {
          metrics: {
            enabled: true
            kubeStateMetrics: {
              metricLabelsAllowlist: ''
              metricAnnotationsAllowList: ''
            }
          }
        }
      : null
    webApplicationRoutingEnabled: ingressType == 'managedNginx'

    // Lifecycle
    autoUpgradeProfile: {
      upgradeChannel: 'stable'
      nodeOSUpgradeChannel: 'NodeImage'
    }
    maintenanceConfigurations: maintenanceConfigs

    diagnosticSettings: [
      {
        name: 'diag'
        workspaceResourceId: logAnalyticsWorkspaceResourceId
      }
    ]
  }
}

@description('AKS cluster name.')
output aksClusterName string = managedCluster.outputs.name

@description('AKS cluster resource ID.')
output aksClusterResourceId string = managedCluster.outputs.resourceId

@description('AKS node (managed) resource group name.')
output aksNodeResourceGroup string = naming.nodeResourceGroup

@description('AKS control plane FQDN.')
output aksControlPlaneFqdn string = managedCluster.outputs.controlPlaneFQDN

@description('OIDC issuer URL (Workload Identity federation).')
output aksOidcIssuerUrl string = managedCluster.outputs.?oidcIssuerUrl ?? ''

@description('Kubelet (node) identity object ID — grant AcrPull.')
output aksKubeletIdentityObjectId string = managedCluster.outputs.?kubeletIdentityObjectId ?? ''

@description('Kubelet (node) identity client ID.')
output aksKubeletIdentityClientId string = managedCluster.outputs.?kubeletIdentityClientId ?? ''

@description('Kubelet (node) identity resource ID.')
output aksKubeletIdentityResourceId string = managedCluster.outputs.?kubeletIdentityResourceId ?? ''

@description('Key Vault CSI add-on identity object ID — grant Key Vault Secrets User.')
output aksKeyVaultIdentityObjectId string = managedCluster.outputs.?keyvaultIdentityObjectId ?? ''

@description('Cluster system-assigned principal ID (empty for user-assigned identity).')
output aksClusterPrincipalId string = managedCluster.outputs.?systemAssignedMIPrincipalId ?? ''
