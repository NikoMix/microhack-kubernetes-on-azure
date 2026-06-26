Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'

function Write-LogMessage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Info', 'Warn', 'Error', 'Success')]
        [string]$Level,

        [Parameter(Mandatory)]
        [string]$Message
    )

    $timestamp = (Get-Date).ToString('yyyy-MM-ddTHH:mm:sszzz')
    $color = switch ($Level) {
        'Info' { "`e[36m" }
        'Warn' { "`e[33m" }
        'Error' { "`e[31m" }
        'Success' { "`e[32m" }
    }
    $reset = "`e[0m"
    Write-Information -MessageData ("{0}[{1}] [{2}] {3}{4}" -f $color, $timestamp, $Level.ToUpperInvariant(), $Message, $reset) -Tags $Level
}

function Test-Command {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    return $null -ne (Get-Command -Name $Name -ErrorAction SilentlyContinue)
}

function Invoke-Native {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Command,

        [Parameter()]
        [string[]]$ArgumentList = @(),

        [Parameter()]
        [string]$FailureMessage = ''
    )

    Write-LogMessage -Level Info -Message ("$Command {0}" -f ($ArgumentList -join ' '))
    & $Command @ArgumentList
    $exitCode = if ($null -ne $LASTEXITCODE) { $LASTEXITCODE } else { 0 }
    if ($exitCode -ne 0) {
        if ([string]::IsNullOrWhiteSpace($FailureMessage)) {
            $FailureMessage = "Command failed with exit code ${exitCode}: $Command $($ArgumentList -join ' ')"
        }
        throw $FailureMessage
    }
}

function Get-AzAccountContext {
    [CmdletBinding()]
    param()

    if (-not (Test-Command -Name 'az')) {
        throw 'Azure CLI (az) is required but was not found on PATH.'
    }

    $json = & az account show --output json 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($json)) {
        throw 'Azure CLI is not logged in. Run az login and retry.'
    }

    return $json | ConvertFrom-Json
}

function Confirm-Action {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [Parameter()]
        [bool]$Force = $false
    )

    if ($Force) {
        return $true
    }

    $answer = Read-Host "$Message [y/N]"
    return $answer -match '^(y|yes)$'
}

