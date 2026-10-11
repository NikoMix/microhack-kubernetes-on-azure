<#
.SYNOPSIS
Connects Flux v2 GitOps to an existing AKS cluster using the AKS GitOps extension.
.PARAMETER ResourceGroupName
Resource group containing the AKS cluster.
.PARAMETER ClusterName
AKS cluster name.
.PARAMETER Subscription
Azure subscription ID or name. Defaults to AZURE_SUBSCRIPTION_ID when set.
.PARAMETER GitOpsRepoUrl
Git repository URL. Defaults to git remote get-url origin.
.PARAMETER Branch
Git branch to reconcile. Defaults to main.
.PARAMETER GitOpsPath
Path in the GitOps repo. Defaults to ./gitops/clusters/microhack.
.PARAMETER Force
Deletes and recreates an existing Flux configuration without prompting.
.PARAMETER Help
Shows detailed help.
.EXAMPLE
./scripts/bootstrap-gitops.ps1 -ResourceGroupName rg-mhaks-dev -ClusterName aks-mhaks-dev
.EXAMPLE
./scripts/bootstrap-gitops.ps1 -ResourceGroupName rg -ClusterName aks -GitOpsRepoUrl https://github.com/org/repo.git -Force
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string]$ResourceGroupName,
    [Parameter(Mandatory)] [string]$ClusterName,
    [Parameter()] [string]$Subscription = $env:AZURE_SUBSCRIPTION_ID,
    [Parameter()] [string]$GitOpsRepoUrl = '',
    [Parameter()] [string]$Branch = 'main',
    [Parameter()] [string]$GitOpsPath = './gitops/clusters/microhack',
    [Parameter()] [switch]$Force,
    [Parameter()] [Alias('h', 'help')] [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib/common.ps1')

if ($Help) { Get-Help -Path $PSCommandPath -Detailed; return }
if (-not [string]::IsNullOrWhiteSpace($Subscription)) {
    Invoke-Native -Command 'az' -ArgumentList @('account', 'set', '--subscription', $Subscription) -FailureMessage "Failed to select subscription '$Subscription'."
}
if ([string]::IsNullOrWhiteSpace($GitOpsRepoUrl)) {
    $repoRoot = Split-Path -Parent $PSScriptRoot
    $GitOpsRepoUrl = (& git -C $repoRoot remote get-url origin 2>$null)
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($GitOpsRepoUrl)) { throw 'GitOpsRepoUrl was not provided and git remote get-url origin failed.' }
}

Invoke-Native -Command 'az' -ArgumentList @('aks', 'get-credentials', '--resource-group', $ResourceGroupName, '--name', $ClusterName, '--overwrite-existing') -FailureMessage 'Failed to get AKS credentials.'
Invoke-Native -Command 'az' -ArgumentList @('extension', 'add', '--name', 'k8s-configuration', '--upgrade') -FailureMessage 'Failed to install or upgrade k8s-configuration extension.'
Invoke-Native -Command 'az' -ArgumentList @('extension', 'add', '--name', 'k8s-extension', '--upgrade') -FailureMessage 'Failed to install or upgrade k8s-extension extension.'
Invoke-Native -Command 'az' -ArgumentList @('provider', 'register', '--namespace', 'Microsoft.KubernetesConfiguration') -FailureMessage 'Failed to register Microsoft.KubernetesConfiguration provider.'
Invoke-Native -Command 'az' -ArgumentList @('provider', 'show', '--namespace', 'Microsoft.KubernetesConfiguration', '--query', 'registrationState', '--output', 'tsv') -FailureMessage 'Failed to query provider registration state.'

$configurationName = 'microhack-flux'
$null = & az k8s-configuration flux show --resource-group $ResourceGroupName --cluster-name $ClusterName --cluster-type managedClusters --name $configurationName --output none 2>$null
if ($LASTEXITCODE -eq 0) {
    if (-not (Confirm-Action -Message "Flux configuration '$configurationName' already exists. Delete and recreate it?" -Force:$Force.IsPresent)) {
        Write-LogMessage -Level Warn -Message 'Existing Flux configuration left unchanged.'
        exit 0
    }
    Invoke-Native -Command 'az' -ArgumentList @('k8s-configuration', 'flux', 'delete', '--resource-group', $ResourceGroupName, '--cluster-name', $ClusterName, '--cluster-type', 'managedClusters', '--name', $configurationName, '--yes') -FailureMessage 'Failed to delete existing Flux configuration.'
}

Invoke-Native -Command 'az' -ArgumentList @(
    'k8s-configuration', 'flux', 'create',
    '--resource-group', $ResourceGroupName,
    '--cluster-name', $ClusterName,
    '--cluster-type', 'managedClusters',
    '--name', $configurationName,
    '--namespace', 'flux-system',
    '--scope', 'cluster',
    '--url', $GitOpsRepoUrl,
    '--branch', $Branch,
    '--kustomization', "name=cluster path=$GitOpsPath prune=true",
    '--sync-interval', '5m'
) -FailureMessage 'Failed to create Flux configuration.'

# Fallback option for environments that cannot use the AKS extension: flux bootstrap git, when the flux CLI is installed.
Write-LogMessage -Level Success -Message 'Flux GitOps configuration is connected.'
