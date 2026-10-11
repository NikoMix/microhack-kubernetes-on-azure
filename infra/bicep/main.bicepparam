using './main.bicep'

// =============================================================================
//  Example parameters for the AKS secure baseline.
//  Copy/adjust per environment. NO secrets belong in this file — identity and
//  access are driven by Microsoft Entra object IDs (not credentials).
// =============================================================================

param location = 'westeurope'
param environment = 'dev'
param workloadName = 'mhaks'

// --- Tags (merged with workload/environment/managed-by) ---
param tags = {
  project: 'microhack-kubernetes-on-azure'
  module: 'B'
  costCenter: 'training'
}

// --- Networking ---
param vnetAddressSpace = '10.0.0.0/16'
param networkDataplane = 'cilium'
param deployFirewall = false
param enablePrivateCluster = false
param enableApiServerVnetIntegration = false
param enablePrivateEndpoints = false

// --- Node pools ---
param systemNodePoolVmSize = 'Standard_D4ds_v5'
param userNodePoolVmSize = 'Standard_D4ds_v5'
param nodePoolAvailabilityZones = [1, 2, 3]

// --- Identity & access ---
// Populate with the object IDs of the Microsoft Entra groups that should be
// cluster administrators (Azure RBAC). Leave empty for none.
param adminGroupObjectIds = []
param authorizedIpRanges = []

// --- Ingress ---
// Lab default: 'none'. The Flux GitOps stack (gitops/) installs ingress-nginx
// (ingressClass 'nginx') as the single ingress controller, which the sample apps
// and cert-manager target. 'managedNginx' (AKS app-routing add-on) and
// 'appGatewayForContainers' remain B.3.1 design-area alternatives — if you select
// one, align the app Ingress ingressClassName + cert-manager solver class to match.
param ingressType = 'none'

// --- Add-ons / security ---
param enableWorkloadIdentity = true
param enableKeyVaultCsi = true
param enableDefenderForContainers = true
param enableAzurePolicy = true
param enableImageCleaner = true

// --- Observability ---
param enableContainerInsights = true
param enableManagedPrometheus = true
param enableManagedGrafana = true
// Object IDs of Entra groups granted the Grafana Admin role.
param grafanaAdminObjectIds = []
param logAnalyticsRetentionInDays = 30

// --- Registry ---
param acrSku = 'Premium'

// --- Cost ---
param enableBudget = true
param monthlyBudgetAmount = 1000
param budgetAlertEmails = []
