<#
.SYNOPSIS
Validates local and Azure readiness for the AKS MicroHack infrastructure lab.
.PARAMETER Subscription
Azure subscription ID or name. Defaults to AZURE_SUBSCRIPTION_ID when set.
.PARAMETER Location
Azure region to validate. Defaults to westeurope.
.PARAMETER Track
Infrastructure track to validate: bicep or terraform. Defaults to bicep.
.PARAMETER Help
Shows detailed help.
.EXAMPLE
./scripts/preflight.ps1 -Location westeurope -Track bicep
.EXAMPLE
./scripts/preflight.ps1 -Subscription <subscription-id> -Track terraform
#>
[CmdletBinding()]
param(
    [Parameter()]
    [string]$Subscription = $env:AZURE_SUBSCRIPTION_ID,

    [Parameter()]
    [string]$Location = 'westeurope',

    [Parameter()]
    [ValidateSet('bicep', 'terraform')]
    [string]$Track = 'bicep',

    [Parameter()]
    [Alias('h', 'help')]
    [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib/common.ps1')

if ($Help) {
    Get-Help -Path $PSCommandPath -Detailed
    return
}

$checks = [System.Collections.Generic.List[object]]::new()
$hardFailures = 0

function Add-CheckResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$Name,
        [Parameter(Mandatory)] [ValidateSet('PASS', 'WARN', 'FAIL')] [string]$Status,
        [Parameter(Mandatory)] [string]$Detail,
        [Parameter()] [bool]$Hard = $false
    )
    $script:checks.Add([pscustomobject]@{ Check = $Name; Status = $Status; Detail = $Detail })
    if ($Status -eq 'FAIL' -and $Hard) { $script:hardFailures++ }
}

try {
    foreach ($command in @('az', 'kubectl', 'helm')) {
        if (Test-Command -Name $command) { Add-CheckResult -Name "CLI: $command" -Status PASS -Detail 'Found on PATH' -Hard }
        else { Add-CheckResult -Name "CLI: $command" -Status FAIL -Detail 'Missing from PATH' -Hard }
    }

    if ($Track -eq 'terraform') {
        if (Test-Command -Name 'terraform') { Add-CheckResult -Name 'CLI: terraform' -Status PASS -Detail 'Found on PATH' -Hard }
        else { Add-CheckResult -Name 'CLI: terraform' -Status FAIL -Detail 'Missing from PATH' -Hard }
    }
    else {
        if (Test-Command -Name 'az') {
            $null = & az bicep version 2>$null
            if ($LASTEXITCODE -eq 0) { Add-CheckResult -Name 'CLI: bicep' -Status PASS -Detail 'az bicep is available' -Hard }
            else { Add-CheckResult -Name 'CLI: bicep' -Status FAIL -Detail 'az bicep version failed' -Hard }
        }
        else { Add-CheckResult -Name 'CLI: bicep' -Status FAIL -Detail 'az is required to validate bicep' -Hard }
    }

    foreach ($optionalCommand in @('gh', 'flux')) {
        if (Test-Command -Name $optionalCommand) { Add-CheckResult -Name "Optional CLI: $optionalCommand" -Status PASS -Detail 'Found on PATH' }
        else { Add-CheckResult -Name "Optional CLI: $optionalCommand" -Status WARN -Detail 'Missing; some optional workflows may be unavailable' }
    }

    if (-not [string]::IsNullOrWhiteSpace($Subscription) -and (Test-Command -Name 'az')) {
        Invoke-Native -Command 'az' -ArgumentList @('account', 'set', '--subscription', $Subscription) -FailureMessage "Failed to select subscription '$Subscription'."
    }

    $account = Get-AzAccountContext
    Add-CheckResult -Name 'Azure login' -Status PASS -Detail ("{0} ({1}), tenant {2}" -f $account.name, $account.id, $account.tenantId) -Hard
    Write-LogMessage -Level Info -Message ("Using subscription '{0}' ({1}), tenant {2}." -f $account.name, $account.id, $account.tenantId)

    $locationCount = & az account list-locations --query "[?name=='$Location'] | length(@)" --output tsv
    if ($LASTEXITCODE -eq 0 -and [int]$locationCount -gt 0) {
        Add-CheckResult -Name 'Azure region' -Status PASS -Detail "$Location is valid" -Hard
    }
    else {
        Add-CheckResult -Name 'Azure region' -Status FAIL -Detail "$Location is not a valid Azure region for this account" -Hard
    }

    $usageJson = & az vm list-usage --location $Location --output json 2>$null
    if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($usageJson)) {
        $usage = $usageJson | ConvertFrom-Json
        $quota = $usage | Where-Object { $_.name.localizedValue -in @('Standard DDSv5 Family vCPUs', 'Standard Dv5 Family vCPUs', 'Total Regional vCPUs') } |
            Sort-Object @{ Expression = { if ($_.name.localizedValue -eq 'Standard DDSv5 Family vCPUs') { 0 } elseif ($_.name.localizedValue -eq 'Standard Dv5 Family vCPUs') { 1 } else { 2 } } } |
            Select-Object -First 1
        if ($null -ne $quota) {
            $available = [int]$quota.limit - [int]$quota.currentValue
            if ($available -ge 16) { Add-CheckResult -Name 'AKS vCPU quota' -Status PASS -Detail ("{0} available in {1}" -f $available, $quota.name.localizedValue) }
            else { Add-CheckResult -Name 'AKS vCPU quota' -Status WARN -Detail ("Only {0} vCPUs available in {1}; 16 recommended" -f $available, $quota.name.localizedValue) }
        }
        else { Add-CheckResult -Name 'AKS vCPU quota' -Status WARN -Detail 'Relevant Dv5/DDv5 quota entry not found' }
    }
    else { Add-CheckResult -Name 'AKS vCPU quota' -Status WARN -Detail 'Unable to query VM usage/quota' }
}
catch {
    Add-CheckResult -Name 'Preflight execution' -Status FAIL -Detail $_.Exception.Message -Hard
}

Write-LogMessage -Level Info -Message 'Preflight summary:'
$checks | Format-Table -AutoSize | Out-String | Write-Information
if ($hardFailures -gt 0) {
    Write-LogMessage -Level Error -Message "Preflight failed with $hardFailures hard failure(s)."
    exit 1
}
Write-LogMessage -Level Success -Message 'Preflight passed.'
