<#
.SYNOPSIS
Deploys or previews the AKS MicroHack infrastructure using Bicep or Terraform.
.PARAMETER Track
Infrastructure track: bicep or terraform. Defaults to bicep.
.PARAMETER Action
whatif previews changes; deploy applies changes. Defaults to whatif.
.PARAMETER Location
Azure deployment location. Defaults to westeurope.
.PARAMETER Environment
Environment name. Defaults to dev.
.PARAMETER WorkloadName
Workload prefix/name. Defaults to mhaks.
.PARAMETER ResourceGroupName
Optional resource group name override passed to IaC.
.PARAMETER Subscription
Azure subscription ID or name. Defaults to AZURE_SUBSCRIPTION_ID when set.
.PARAMETER Force
Skips confirmation prompts for deploy actions.
.PARAMETER Help
Shows detailed help.
.EXAMPLE
./scripts/deploy.ps1 -Track bicep -Action whatif
.EXAMPLE
./scripts/deploy.ps1 -Track terraform -Action deploy -Force
#>
[CmdletBinding()]
param(
    [Parameter()] [ValidateSet('bicep', 'terraform')] [string]$Track = 'bicep',
    [Parameter()] [ValidateSet('whatif', 'deploy')] [string]$Action = 'whatif',
    [Parameter()] [string]$Location = 'westeurope',
    [Parameter()] [string]$Environment = 'dev',
    [Parameter()] [string]$WorkloadName = 'mhaks',
    [Parameter()] [string]$ResourceGroupName = '',
    [Parameter()] [string]$Subscription = $env:AZURE_SUBSCRIPTION_ID,
    [Parameter()] [switch]$Force,
    [Parameter()] [Alias('h', 'help')] [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib/common.ps1')

if ($Help) { Get-Help -Path $PSCommandPath -Detailed; return }

$repoRoot = Split-Path -Parent $PSScriptRoot
if (-not [string]::IsNullOrWhiteSpace($Subscription)) {
    Invoke-Native -Command 'az' -ArgumentList @('account', 'set', '--subscription', $Subscription) -FailureMessage "Failed to select subscription '$Subscription'."
}

if ($Action -eq 'deploy' -and -not (Confirm-Action -Message "Deploy $Track infrastructure to subscription $(Get-AzAccountContext | Select-Object -ExpandProperty id)?" -Force:$Force.IsPresent)) {
    Write-LogMessage -Level Warn -Message 'Deployment cancelled.'
    exit 0
}

$deploymentName = '{0}-{1}-{2}' -f $WorkloadName, $Environment, (Get-Date -Format 'yyyyMMddHHmmss')

if ($Track -eq 'bicep') {
    $templateFile = Join-Path $repoRoot 'infra/bicep/main.bicep'
    $parameterFile = Join-Path $repoRoot 'infra/bicep/main.bicepparam'
    $arguments = @('deployment', 'sub', 'create', '--name', $deploymentName, '--location', $Location, '--template-file', $templateFile, '--parameters', $parameterFile, '--parameters', "location=$Location", "environment=$Environment", "workloadName=$WorkloadName")
    if (-not [string]::IsNullOrWhiteSpace($ResourceGroupName)) { $arguments += "resourceGroupName=$ResourceGroupName" }
    if ($Action -eq 'whatif') { $arguments += '--what-if' }
    Invoke-Native -Command 'az' -ArgumentList $arguments -FailureMessage 'Bicep deployment command failed.'
    if ($Action -eq 'deploy') {
        $outputsJson = & az deployment sub show --name $deploymentName --query properties.outputs --output json
        if ($LASTEXITCODE -ne 0) { throw 'Failed to read Bicep deployment outputs.' }
        $outputs = $outputsJson | ConvertFrom-Json
        Write-LogMessage -Level Success -Message 'Deployment outputs:'
        [pscustomobject]@{
            ResourceGroup = $outputs.resourceGroupName.value
            ClusterName = $outputs.aksClusterName.value
            AcrLoginServer = $outputs.acrLoginServer.value
            GrafanaEndpoint = $outputs.grafanaEndpoint.value
            GetCredentials = $outputs.getCredentialsCommand.value
        } | Format-List | Out-String | Write-Information
    }
}
else {
    $terraformDir = Join-Path $repoRoot 'infra/terraform'
    $varArgs = @('-var', "location=$Location", '-var', "environment=$Environment", '-var', "workload_name=$WorkloadName")
    if (-not [string]::IsNullOrWhiteSpace($ResourceGroupName)) { $varArgs += @('-var', "resource_group_name=$ResourceGroupName") }
    Invoke-Native -Command 'terraform' -ArgumentList @("-chdir=$terraformDir", 'init', '-input=false') -FailureMessage 'Terraform init failed.'
    if ($Action -eq 'whatif') {
        Invoke-Native -Command 'terraform' -ArgumentList (@("-chdir=$terraformDir", 'plan', '-input=false', '-out=tfplan') + $varArgs) -FailureMessage 'Terraform plan failed.'
    }
    else {
        Invoke-Native -Command 'terraform' -ArgumentList (@("-chdir=$terraformDir", 'apply', '-input=false', '-auto-approve') + $varArgs) -FailureMessage 'Terraform apply failed.'
        $outputsJson = & terraform "-chdir=$terraformDir" output -json
        if ($LASTEXITCODE -ne 0) { throw 'Failed to read Terraform outputs.' }
        $outputs = $outputsJson | ConvertFrom-Json
        Write-LogMessage -Level Success -Message 'Deployment outputs:'
        [pscustomobject]@{
            ResourceGroup = $outputs.resource_group_name.value
            ClusterName = $outputs.aks_cluster_name.value
            AcrLoginServer = $outputs.acr_login_server.value
            GrafanaEndpoint = $outputs.grafana_endpoint.value
            GetCredentials = "az aks get-credentials --resource-group $($outputs.resource_group_name.value) --name $($outputs.aks_cluster_name.value) --overwrite-existing"
        } | Format-List | Out-String | Write-Information
    }
}

Write-LogMessage -Level Success -Message "$Track $Action completed."
