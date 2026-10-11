// =============================================================================
//  Observability module — Log Analytics (Container Insights backend), Azure
//  Monitor Workspace (Managed Prometheus), Data Collection Endpoint + Rule, and
//  Azure Managed Grafana with role assignments.
//  AVM: operational-insights/workspace. Raw: Monitor account (AMW), DCE, DCR,
//  Dashboard/grafana (no stable AVM modules at time of authoring).
// =============================================================================

metadata name = 'AKS baseline observability'
metadata description = 'Log Analytics, Azure Monitor Workspace (Managed Prometheus DCE/DCR), and Managed Grafana for the AKS secure baseline.'

@description('Required. Azure region.')
param location string

@description('Required. Resource naming context.')
param naming object

@description('Required. Tags applied to all resources.')
param tags object

@description('Optional. Log Analytics data retention in days.')
@minValue(30)
@maxValue(730)
param logAnalyticsRetentionInDays int = 30

@description('Optional. Daily ingestion cap (GB) for Log Analytics. -1 disables the cap.')
param logAnalyticsDailyQuotaGb int = -1

@description('Optional. Deploy Azure Monitor Workspace + DCE/DCR for Managed Prometheus.')
param deployManagedPrometheus bool = true

@description('Optional. Deploy Azure Managed Grafana.')
param deployGrafana bool = true

@description('Optional. Microsoft Entra object IDs granted the Grafana Admin role.')
param grafanaAdminObjectIds array = []

@description('Optional. Enable AVM telemetry.')
param enableTelemetry bool = true

var monitoringDataReaderRoleId = 'b0d8363b-8ddd-447d-831f-62ca05bff136'
var grafanaAdminRoleId = '22926164-76b3-42b3-bc55-97df8dab3e41'
var amwDestinationName = 'MonitoringAccount'

// --- Log Analytics (Container Insights backend, MSI auth from AKS add-on) ---
module logAnalytics 'br/public:avm/res/operational-insights/workspace:0.15.1' = {
  name: 'law-deploy'
  params: {
    name: naming.logAnalytics
    location: location
    tags: tags
    enableTelemetry: enableTelemetry
    skuName: 'PerGB2018'
    dataRetention: logAnalyticsRetentionInDays
    dailyQuotaGb: string(logAnalyticsDailyQuotaGb)
    diagnosticSettings: [
      {
        name: 'diag'
        useThisWorkspace: true
      }
    ]
  }
}

// --- Azure Monitor Workspace (Managed Prometheus metrics store) ---
resource azureMonitorWorkspace 'Microsoft.Monitor/accounts@2023-04-03' = if (deployManagedPrometheus) {
  name: naming.azureMonitorWorkspace
  location: location
  tags: tags
}

// --- Data Collection Endpoint for Prometheus scraping ---
resource dataCollectionEndpoint 'Microsoft.Insights/dataCollectionEndpoints@2023-03-11' = if (deployManagedPrometheus) {
  name: naming.dataCollectionEndpoint
  location: location
  tags: tags
  kind: 'Linux'
  properties: {
    networkAcls: {
      publicNetworkAccess: 'Enabled'
    }
  }
}

// --- Data Collection Rule routing Prometheus metrics to the Azure Monitor Workspace ---
resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2023-03-11' = if (deployManagedPrometheus) {
  name: naming.dataCollectionRule
  location: location
  tags: tags
  kind: 'Linux'
  properties: {
    dataCollectionEndpointId: deployManagedPrometheus ? dataCollectionEndpoint.id : null
    dataSources: {
      prometheusForwarder: [
        {
          name: 'PrometheusDataSource'
          streams: [
            'Microsoft-PrometheusMetrics'
          ]
          labelIncludeFilter: {}
        }
      ]
    }
    destinations: {
      monitoringAccounts: [
        {
          accountResourceId: deployManagedPrometheus ? azureMonitorWorkspace.id : null
          name: amwDestinationName
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-PrometheusMetrics'
        ]
        destinations: [
          amwDestinationName
        ]
      }
    ]
  }
}

// --- Azure Managed Grafana ---
resource grafana 'Microsoft.Dashboard/grafana@2024-10-01' = if (deployGrafana) {
  name: naming.grafana
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    apiKey: 'Disabled'
    deterministicOutboundIP: 'Disabled'
    publicNetworkAccess: 'Enabled'
    zoneRedundancy: 'Disabled'
    grafanaIntegrations: {
      azureMonitorWorkspaceIntegrations: deployManagedPrometheus ? [
        {
          azureMonitorWorkspaceResourceId: azureMonitorWorkspace.id
        }
      ] : []
    }
  }
}

// Grant the Grafana managed identity read access to the Azure Monitor Workspace.
resource grafanaAmwReader 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (deployGrafana && deployManagedPrometheus) {
  name: guid(naming.azureMonitorWorkspace, naming.grafana, monitoringDataReaderRoleId)
  scope: azureMonitorWorkspace
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', monitoringDataReaderRoleId)
    principalId: deployGrafana ? grafana!.identity.principalId : ''
    principalType: 'ServicePrincipal'
  }
}

// Grant configured admins the Grafana Admin role.
resource grafanaAdmins 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for adminId in grafanaAdminObjectIds: if (deployGrafana) {
  name: guid(naming.grafana, adminId, grafanaAdminRoleId)
  scope: grafana
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', grafanaAdminRoleId)
    principalId: adminId
    principalType: 'Group'
  }
}]

@description('Log Analytics workspace resource ID (Container Insights backend).')
output logAnalyticsWorkspaceResourceId string = logAnalytics.outputs.resourceId

@description('Log Analytics workspace customer (workspace) ID.')
output logAnalyticsWorkspaceCustomerId string = logAnalytics.outputs.logAnalyticsWorkspaceId

@description('Azure Monitor Workspace resource ID (empty when Managed Prometheus is disabled).')
output azureMonitorWorkspaceResourceId string = deployManagedPrometheus ? azureMonitorWorkspace.id : ''

@description('Azure Monitor Workspace Prometheus query endpoint (empty when disabled).')
output azureMonitorWorkspacePrometheusEndpoint string = deployManagedPrometheus ? azureMonitorWorkspace!.properties.metrics.prometheusQueryEndpoint : ''

@description('Data Collection Rule resource ID for Prometheus (empty when disabled).')
output dataCollectionRuleResourceId string = deployManagedPrometheus ? dataCollectionRule.id : ''

@description('Data Collection Endpoint resource ID (empty when disabled).')
output dataCollectionEndpointResourceId string = deployManagedPrometheus ? dataCollectionEndpoint.id : ''

@description('Managed Grafana resource ID (empty when Grafana is disabled).')
output grafanaResourceId string = deployGrafana ? grafana.id : ''

@description('Managed Grafana endpoint URL (empty when Grafana is disabled).')
output grafanaEndpoint string = deployGrafana ? grafana!.properties.endpoint : ''
