# Windows Application Updater

PowerShell audit and optional update workflow for applications supported by WinGet.

> **Testing note:** This was tested by me to be working. User experience may vary.

Included script: `Update-WindowsApplications.ps1`

```powershell
.\Update-WindowsApplications.ps1
.\Update-WindowsApplications.ps1 -Upgrade
.\Update-WindowsApplications.ps1 -Upgrade -WhatIf
```

The default mode records installed applications and available updates. `-Upgrade` requests installation of available WinGet updates.

Logs are written to `C:\ProgramData\WindowsApplicationUpdater\Logs`.

Exit codes: `0` success, `1` fatal error, `2` WinGet returned a non-zero result.

Use this project at your own risk. Review available updates and maintain current backups before applying software changes.

MIT License.
