<#
.SYNOPSIS
Summarizes month-to-date Azure spend for the lab resource group.
.PARAMETER ResourceGroupName
Lab resource group name.
.PARAMETER Subscription
Azure subscription ID or name. Defaults to AZURE_SUBSCRIPTION_ID when set.
.PARAMETER Help
Shows detailed help.
.EXAMPLE
./scripts/cost-report.ps1 -ResourceGroupName rg-mhaks-dev
.EXAMPLE
./scripts/cost-report.ps1 -ResourceGroupName rg-mhaks-dev -Subscription <subscription-id>
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string]$ResourceGroupName,
    [Parameter()] [string]$Subscription = $env:AZURE_SUBSCRIPTION_ID,
    [Parameter()] [Alias('h', 'help')] [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib/common.ps1')

if ($Help) { Get-Help -Path $PSCommandPath -Detailed; return }
if (-not [string]::IsNullOrWhiteSpace($Subscription)) {
    Invoke-Native -Command 'az' -ArgumentList @('account', 'set', '--subscription', $Subscription) -FailureMessage "Failed to select subscription '$Subscription'."
}
$account = Get-AzAccountContext
$scope = "/subscriptions/$($account.id)/resourceGroups/$ResourceGroupName"
$startDate = (Get-Date -Day 1).ToString('yyyy-MM-dd')
$endDate = (Get-Date).ToString('yyyy-MM-dd')
$costRows = @()

$costJson = & az costmanagement query --scope $scope --type ActualCost --timeframe Custom --time-period from=$startDate to=$endDate --dataset-granularity None --dataset-grouping name=ResourceType type=Dimension --dataset-aggregation name=Cost function=Sum --output json 2>$null
if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($costJson)) {
    $costResult = $costJson | ConvertFrom-Json
    $columnNames = @($costResult.properties.columns | ForEach-Object { $_.name })
    $resourceTypeIndex = [array]::IndexOf($columnNames, 'ResourceType')
    $costIndex = [array]::IndexOf($columnNames, 'Cost')
    if ($costIndex -lt 0) { $costIndex = [array]::IndexOf($columnNames, 'PreTaxCost') }
    if ($resourceTypeIndex -lt 0 -or $costIndex -lt 0) {
        Write-LogMessage -Level Warn -Message 'Cost Management response did not include expected Cost and ResourceType columns.'
    }
    else {
        foreach ($row in $costResult.properties.rows) {
            if ($row.Count -gt [Math]::Max($resourceTypeIndex, $costIndex)) {
                $costRows += [pscustomobject]@{ ResourceType = [string]$row[$resourceTypeIndex]; Cost = [decimal]$row[$costIndex] }
            }
        }
    }
}
else {
    Write-LogMessage -Level Warn -Message 'az costmanagement query unavailable; falling back to az consumption usage list.'
    $usageJson = & az consumption usage list --start-date $startDate --end-date $endDate --output json 2>$null
    if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($usageJson)) {
        $usage = $usageJson | ConvertFrom-Json | Where-Object { $_.resourceGroup -eq $ResourceGroupName }
        $costRows = $usage | Group-Object -Property consumedService | ForEach-Object {
            [pscustomobject]@{ ResourceType = if ($_.Name) { $_.Name } else { 'Unknown' }; Cost = [decimal](($_.Group | Measure-Object -Property pretaxCost -Sum).Sum) }
        }
    }
}

if ($costRows.Count -eq 0) {
    Write-LogMessage -Level Warn -Message 'No month-to-date cost data found for the resource group.'
}
else {
    $total = [decimal](($costRows | Measure-Object -Property Cost -Sum).Sum)
    $costRows | Sort-Object ResourceType | Format-Table ResourceType, @{ Label = 'Cost'; Expression = { '{0:N2}' -f $_.Cost } } -AutoSize | Out-String | Write-Information
    Write-LogMessage -Level Success -Message ("Month-to-date total estimate/actual: {0:N2}" -f $total)
}

Write-LogMessage -Level Info -Message 'Estimated daily baseline guidance (varies by SKU, region, usage, and discounts): AKS nodes, ACR Premium, Log Analytics ingestion/retention, Azure Managed Grafana, and Azure Monitor Workspace may continue to accrue cost while deployed.'

