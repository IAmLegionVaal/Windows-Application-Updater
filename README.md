# Windows Application Updater

PowerShell audit and optional update workflow for applications supported by WinGet.

> **Testing note:** This was tested by me to be working. User experience may vary.

## One-click use

1. Download and extract the repository.
2. Double-click `Run-OneClick.bat`.
3. The launcher checks WinGet and installs all available supported application updates non-interactively. There is no menu.
4. Review the displayed exit code and logs in `C:\ProgramData\WindowsApplicationUpdater\Logs`.

Included script: `Update-WindowsApplications.ps1`

## PowerShell usage

```powershell
.\Update-WindowsApplications.ps1
.\Update-WindowsApplications.ps1 -Upgrade
.\Update-WindowsApplications.ps1 -Upgrade -WhatIf
```

The default PowerShell mode records installed applications and available updates. `-Upgrade` accepts required source and package agreements, disables interactive prompts, requests all available WinGet upgrades and records the remaining update list.

Exit codes: `0` success, `1` fatal error, `2` WinGet or verification warnings.

Review available updates and maintain current backups before applying software changes. MIT License.
