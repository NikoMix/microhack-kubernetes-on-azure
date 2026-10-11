<#
.SYNOPSIS
Deletes billable AKS MicroHack infrastructure resources.
.PARAMETER Track
Infrastructure track: bicep or terraform. Defaults to bicep.
.PARAMETER ResourceGroupName
Resource group to delete for the bicep track, or an optional existence check for terraform.
.PARAMETER Subscription
Azure subscription ID or name. Defaults to AZURE_SUBSCRIPTION_ID when set.
.PARAMETER Force
Skips confirmation prompts.
.PARAMETER Wait
Waits for resource group deletion in the bicep track. Defaults to no-wait.
.PARAMETER Help
Shows detailed help.
.EXAMPLE
./scripts/teardown.ps1 -Track bicep -ResourceGroupName rg-mhaks-dev -Force
.EXAMPLE
./scripts/teardown.ps1 -Track terraform -Force
#>
[CmdletBinding()]
param(
    [Parameter()] [ValidateSet('bicep', 'terraform')] [string]$Track = 'bicep',
    [Parameter()] [string]$ResourceGroupName = '',
    [Parameter()] [string]$Subscription = $env:AZURE_SUBSCRIPTION_ID,
    [Parameter()] [switch]$Force,
    [Parameter()] [switch]$Wait,
    [Parameter()] [Alias('h', 'help')] [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib/common.ps1')

if ($Help) { Get-Help -Path $PSCommandPath -Detailed; return }
if (-not [string]::IsNullOrWhiteSpace($Subscription)) {
    Invoke-Native -Command 'az' -ArgumentList @('account', 'set', '--subscription', $Subscription) -FailureMessage "Failed to select subscription '$Subscription'."
}

if ($Track -eq 'bicep') {
    if ([string]::IsNullOrWhiteSpace($ResourceGroupName)) { throw 'ResourceGroupName is required for bicep teardown.' }
    $null = & az group show --name $ResourceGroupName --output none 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-LogMessage -Level Success -Message "Resource group '$ResourceGroupName' does not exist; nothing to delete."
        exit 0
    }
    if (-not (Confirm-Action -Message "Delete resource group '$ResourceGroupName' and all billable lab resources?" -Force:$Force.IsPresent)) {
        Write-LogMessage -Level Warn -Message 'Teardown cancelled.'
        exit 0
    }
    $arguments = @('group', 'delete', '--name', $ResourceGroupName, '--yes')
    if (-not $Wait.IsPresent) { $arguments += '--no-wait' }
    Invoke-Native -Command 'az' -ArgumentList $arguments -FailureMessage 'Resource group deletion failed.'
}
else {
    $repoRoot = Split-Path -Parent $PSScriptRoot
    $terraformDir = Join-Path $repoRoot 'infra/terraform'
    if (-not (Confirm-Action -Message 'Destroy Terraform-managed lab resources?' -Force:$Force.IsPresent)) {
        Write-LogMessage -Level Warn -Message 'Teardown cancelled.'
        exit 0
    }
    Invoke-Native -Command 'terraform' -ArgumentList @("-chdir=$terraformDir", 'destroy', '-auto-approve') -FailureMessage 'Terraform destroy failed.'
}

Write-LogMessage -Level Warn -Message 'Soft-deleted Key Vaults with purge protection enabled persist until their retention window expires. This is intentional best practice and cannot be purged early.'
Write-LogMessage -Level Success -Message 'Teardown command completed.'
