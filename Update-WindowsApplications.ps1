<#
.SYNOPSIS
Reports and optionally installs WinGet application updates.
#>
[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [switch]$Upgrade,
    [string]$LogRoot="$env:ProgramData\WindowsApplicationUpdater\Logs"
)

Set-StrictMode -Version 2.0
$ErrorActionPreference='Stop'
$runPath=Join-Path $LogRoot (Get-Date -Format 'yyyyMMdd_HHmmss')
$warnings=New-Object System.Collections.Generic.List[string]

function Invoke-Winget{
    param([string]$Name,[string[]]$Arguments,[switch]$WarnOnFailure)
    $path=Join-Path $runPath ($Name+'.txt')
    winget.exe @Arguments 2>&1|Tee-Object -FilePath $path
    $code=$LASTEXITCODE
    if($WarnOnFailure -and $code -ne 0){$script:warnings.Add("$Name returned $code")}
    $code
}

try{
    if($env:OS -ne 'Windows_NT'){throw 'Windows is required.'}
    if(-not(Get-Command winget.exe -ErrorAction SilentlyContinue)){throw 'WinGet was not found.'}
    New-Item $runPath -ItemType Directory -Force|Out-Null

    [void](Invoke-Winget 'WingetInfo' @('--info') -WarnOnFailure)
    [void](Invoke-Winget 'InstalledApplications' @('list','--accept-source-agreements','--disable-interactivity') -WarnOnFailure)
    [void](Invoke-Winget 'AvailableUpgrades-Before' @('upgrade','--accept-source-agreements','--disable-interactivity') -WarnOnFailure)

    $upgradeCode=0
    if($Upgrade -and $PSCmdlet.ShouldProcess('Applications listed by WinGet','Install available updates')){
        $upgradeCode=Invoke-Winget 'UpgradeResults' @(
            'upgrade','--all','--accept-package-agreements','--accept-source-agreements','--disable-interactivity'
        )
        if($upgradeCode -ne 0){$warnings.Add("WinGet upgrade returned $upgradeCode")}
        [void](Invoke-Winget 'AvailableUpgrades-After' @('upgrade','--accept-source-agreements','--disable-interactivity') -WarnOnFailure)
    }

    [pscustomobject]@{
        Computer=$env:COMPUTERNAME
        UpgradeRequested=[bool]$Upgrade
        UpgradeExitCode=$upgradeCode
        WarningCount=$warnings.Count
        Completed=Get-Date
    }|ConvertTo-Json|Out-File (Join-Path $runPath 'Summary.json') -Encoding UTF8

    $warnings|Out-File (Join-Path $runPath 'Warnings.txt') -Encoding UTF8
    if($warnings.Count -gt 0){Write-Host "[WARN] Completed with warnings. Logs: $runPath" -ForegroundColor Yellow;exit 2}
    Write-Host "[OK] Completed. Logs: $runPath" -ForegroundColor Green;exit 0
}catch{Write-Error $_.Exception.Message;exit 1}
