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

try{
    if($env:OS -ne 'Windows_NT'){throw 'Windows is required.'}
    if(-not(Get-Command winget.exe -ErrorAction SilentlyContinue)){throw 'WinGet was not found.'}
    New-Item $runPath -ItemType Directory -Force|Out-Null

    winget.exe --info 2>&1|Out-File (Join-Path $runPath 'WingetInfo.txt')
    winget.exe list 2>&1|Out-File (Join-Path $runPath 'InstalledApplications.txt')
    winget.exe upgrade 2>&1|Out-File (Join-Path $runPath 'AvailableUpgrades.txt')

    $code=0
    if($Upgrade -and $PSCmdlet.ShouldProcess('Applications listed by WinGet','Install available updates')){
        winget.exe upgrade --all 2>&1|Tee-Object -FilePath (Join-Path $runPath 'UpgradeResults.txt')
        $code=$LASTEXITCODE
        winget.exe upgrade 2>&1|Out-File (Join-Path $runPath 'RemainingUpgrades.txt')
    }

    [pscustomobject]@{Computer=$env:COMPUTERNAME;UpgradeRequested=[bool]$Upgrade;ExitCode=$code;Completed=Get-Date}|
        ConvertTo-Json|Out-File (Join-Path $runPath 'Summary.json')

    if($code -ne 0){Write-Host "[WARN] WinGet returned $code. Logs: $runPath" -ForegroundColor Yellow;exit 2}
    Write-Host "[OK] Completed. Logs: $runPath" -ForegroundColor Green;exit 0
}catch{Write-Error $_.Exception.Message;exit 1}
